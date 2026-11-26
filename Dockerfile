# syntax=docker/dockerfile:1
ARG distro=ubuntu
FROM rust:1.96.1-slim-bookworm@sha256:e18a79fc84dfcfc3ab5ba72290398a644c135c97eaa881447fddc354ee4701a3 AS rust-toolchain
FROM starrocks/toolchains-${distro}:main-20261029 AS builder
ENV RUSTUP_HOME=/opt/rustup CARGO_HOME=/opt/cargo
ENV PATH=/opt/cargo/bin:${STARROCKS_GCC_HOME}/bin:${PATH}
COPY --from=rust-toolchain /usr/local/rustup/ /opt/rustup/
COPY --from=rust-toolchain /usr/local/cargo/ /opt/cargo/
WORKDIR /src
COPY ci-protoc.py /src/
RUN python3 ci-protoc.py
COPY Cargo.toml Cargo.lock ./
RUN mkdir -p src && touch src/lib.rs && cargo fetch --locked
COPY . .
RUN python3 -m unittest test_build && \
    python3 build.py --prefix /out/lance --protoc /opt/protoc/bin/protoc -j 2
FROM scratch AS package
COPY --from=builder /out/ /
