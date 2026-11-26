"""Install the checksum-pinned build-time protobuf compiler."""
import hashlib
import io
import platform
import urllib.request
import zipfile
from pathlib import Path

artifacts = {
    "x86_64": ("x86_64", "6dab2adab83f915126cab53540d48957c40e9e9023969c3e84d44bfb936c7741"),
    "aarch64": ("aarch_64", "bdad36f3ad7472281d90568c4956ea2e203c216e0de005c6bd486f1920f2751c"),
}
arch, expected = artifacts[platform.machine()]
url = f"https://github.com/protocolbuffers/protobuf/releases/download/v27.3/protoc-27.3-linux-{arch}.zip"
with urllib.request.urlopen(url) as response:
    data = response.read()
if hashlib.sha256(data).hexdigest() != expected:
    raise RuntimeError("protoc checksum mismatch")
with zipfile.ZipFile(io.BytesIO(data)) as archive:
    archive.extractall("/opt/protoc")
Path("/opt/protoc/bin/protoc").chmod(0o755)
