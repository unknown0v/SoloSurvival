"""Verify the deployed source identity and HTML from the ephemeral cloud runner."""
import json
import os
from pathlib import Path
import time
import urllib.request
import urllib.error

metadata = json.loads(Path("build/hosting.json").read_text(encoding="utf-8"))
url = metadata.get("url")
if not url:
    raise SystemExit("Owner Pages setup is still required; no hosted runtime claim.")
url = url.rstrip("/") + "/"
expected = os.environ["GITHUB_SHA"]
last = ""
for attempt in range(40):
    try:
        request = urllib.request.Request(url + "solosurvival-build.json?build=" + expected,headers={"Cache-Control":"no-cache"})
        with urllib.request.urlopen(request, timeout=15) as response:
            marker = json.load(response)
        if marker.get("source_commit") != expected:
            raise ValueError("Pages has not deployed the expected source commit yet")
        with urllib.request.urlopen(url + "index.html?build=" + expected,timeout=15) as response:
            html = response.read().decode("utf-8")
        assert "<canvas" in html and "index.js" in html and "index.pck" in html
        print("HOSTED_WEB_READY " + url,flush=True)
        Path("build/hosted-url.txt").write_text(url + "index.html?build=" + expected,encoding="utf-8")
        break
    except (urllib.error.URLError, ValueError, AssertionError) as error:
        last = str(error)
        print("Waiting for Pages deployment: " + last,flush=True)
        time.sleep(3)
else:
    raise SystemExit("Hosted source could not be verified: " + last)
