"""Install pinned official Godot binaries into an ephemeral CLOUD runner only."""
import hashlib
import os
from pathlib import Path
import shutil
import tempfile
import urllib.request
import zipfile

VERSION = "4.7.2"
BASE = f"https://github.com/godotengine/godot-builds/releases/download/{VERSION}-stable/"
ASSETS = {
    f"Godot_v{VERSION}-stable_linux.x86_64.zip": "cadd3204e728a35d3f13adb7fd0d7902636b79f6b95c40c265eb73b6c35329e4",
    f"Godot_v{VERSION}-stable_export_templates.tpz": "f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011",
}

def main():
    if os.environ.get("GITHUB_ACTIONS") != "true":
        raise SystemExit("This installer is restricted to GitHub-hosted cloud CI. No local installation.")
    root = Path(os.environ["RUNNER_TEMP"]) / "solosurvival-toolchain"
    root.mkdir(parents=True, exist_ok=True)
    for name, expected in ASSETS.items():
        target = root / name
        print(f"Downloading official {name}", flush=True)
        with urllib.request.urlopen(BASE + name, timeout=120) as response, target.open("wb") as out:
            shutil.copyfileobj(response, out)
        digest = hashlib.file_digest(target.open("rb"), "sha256").hexdigest()
        if digest != expected:
            raise SystemExit(f"Checksum mismatch: {name}")
        with zipfile.ZipFile(target) as archive:
            if name.endswith(".zip"):
                binary_name = f"Godot_v{VERSION}-stable_linux.x86_64"
                with archive.open(binary_name) as src, (root / "godot").open("wb") as dest:
                    shutil.copyfileobj(src, dest)
                (root / "godot").chmod(0o755)
            else:
                templates = Path.home() / ".local/share/godot/export_templates" / f"{VERSION}.stable"
                templates.mkdir(parents=True, exist_ok=True)
                required = ["web_nothreads_release.zip", "web_nothreads_debug.zip", "windows_release_x86_64.exe", "windows_debug_x86_64.exe"]
                for filename in required:
                    with archive.open("templates/" + filename) as src, (templates / filename).open("wb") as dest:
                        shutil.copyfileobj(src, dest)
        target.unlink()
    with open(os.environ["GITHUB_PATH"], "a", encoding="utf-8") as out:
        out.write(str(root) + "\n")

if __name__ == "__main__":
    main()
