"""Validate the real exported HTML5 bundle against itch.io's documented limits."""
from pathlib import Path
import json
import sys
import shutil
import urllib.request
import zipfile

for name in ["LICENSE.txt", "COPYRIGHT.txt"]:
    url = "https://raw.githubusercontent.com/godotengine/godot/4.7.2-stable/" + name
    with urllib.request.urlopen(url, timeout=30) as response:
        notice = response.read()
    for directory in ["build/web", "build/windows"]:
        Path(directory, "GODOT-" + name).write_bytes(notice)
for directory in ["build/web", "build/windows"]:
    shutil.copyfile("LICENSE", Path(directory, "SOLOSURVIVAL-LICENSE.txt"))

root = Path("build/web")
files = [p for p in root.rglob("*") if p.is_file()]
assert (root / "index.html").is_file(), "Missing index.html"
assert any(p.suffix == ".wasm" for p in files), "Missing actual WebAssembly runtime"
assert any(p.suffix == ".pck" for p in files), "Missing Godot game resources"
assert len(files) <= 1000, "itch.io file count limit exceeded"
assert sum(p.stat().st_size for p in files) < 500_000_000, "itch.io extracted size limit exceeded"
for path in files:
    assert path.stat().st_size < 200_000_000, f"itch.io single-file limit: {path}"
    assert len(path.relative_to(root).as_posix()) <= 240, "itch.io path length exceeded"
with zipfile.ZipFile("build/SoloSurvival-web.zip", "w", zipfile.ZIP_DEFLATED) as archive:
    for path in files:
        archive.write(path, path.relative_to(root))
with zipfile.ZipFile("build/SoloSurvival-windows.zip", "w", zipfile.ZIP_DEFLATED) as archive:
    for path in Path("build/windows").rglob("*"):
        if path.is_file():
            archive.write(path,path.relative_to("build/windows"))
print(json.dumps({"files":len(files),"unpacked_bytes":sum(p.stat().st_size for p in files)}))
