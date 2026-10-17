"""Publish the validated game to an owned generated branch, then try free Pages setup.

Executed only by the trusted branch's cloud workflow, never on the laptop.
No Actions artifact/cache storage or paid service is used.
"""
import json
import os
from pathlib import Path
import subprocess

def run(*args, cwd=None, check=True):
    return subprocess.run(args, cwd=cwd, check=check, text=True, capture_output=True)

def main():
    if os.environ.get("GITHUB_ACTIONS") != "true":
        raise SystemExit("Cloud CI only.")
    repo = os.environ["GITHUB_REPOSITORY"]
    sha = os.environ["GITHUB_SHA"]
    root = Path("build/web").resolve()
    marker_name = ".solosurvival-generated.json"
    marker = {"generator":"SoloSurvival CI","repository":repo,"source_commit":sha}
    run("gh","auth","setup-git")
    run("git","init",str(root))
    run("git","config","user.name","github-actions[bot]",cwd=root)
    run("git","config","user.email","41898282+github-actions[bot]@users.noreply.github.com",cwd=root)
    run("git","remote","add","origin",f"https://github.com/{repo}.git",cwd=root)
    existing = run("git","ls-remote","--heads","origin","refs/heads/gh-pages",cwd=root).stdout.strip()
    parents = []
    if existing:
        run("git","fetch","--depth=1","origin","gh-pages",cwd=root)
        old = run("git","show",f"FETCH_HEAD:{marker_name}",cwd=root,check=False)
        try:
            ownership = json.loads(old.stdout)
        except (ValueError,TypeError):
            raise SystemExit("Existing gh-pages branch lacks SoloSurvival ownership marker; left untouched.")
        if ownership.get("generator")!="SoloSurvival CI" or ownership.get("repository")!=repo:
            raise SystemExit("Existing gh-pages ownership does not match; left untouched.")
        parents = ["-p",run("git","rev-parse","FETCH_HEAD",cwd=root).stdout.strip()]
    (root / marker_name).write_text(json.dumps(marker)+"\n",encoding="utf-8")
    (root / "solosurvival-build.json").write_text(json.dumps(marker)+"\n",encoding="utf-8")
    (root / ".nojekyll").touch()
    run("git","add","--all",cwd=root)
    tree = run("git","write-tree",cwd=root).stdout.strip()
    commit = run("git","commit-tree",tree,*parents,"-m",f"build: publish validated SoloSurvival {sha[:12]}",cwd=root).stdout.strip()
    run("git","push","origin",f"{commit}:refs/heads/gh-pages",cwd=root)
    print(f"Validated Web files published to {repo}:gh-pages",flush=True)
    result = run("gh","api",f"repos/{repo}/pages",check=False)
    if result.returncode:
        result = run("gh","api","--method","POST",f"repos/{repo}/pages","-f","build_type=legacy","-f","source[branch]=gh-pages","-f","source[path]=/",check=False)
    if result.returncode:
        message = "Web build is ready. Repository owner must enable Settings > Pages > Deploy from a branch > gh-pages / (root). App could not configure Pages."
        print(message,flush=True)
        print(result.stderr,flush=True)
        Path("build/hosting.json").write_text(json.dumps({"status":"owner_action_required","message":message}),encoding="utf-8")
        return
    pages = json.loads(result.stdout)
    source = pages.get("source",{})
    if source.get("branch")!="gh-pages" or source.get("path")!="/":
        print("Existing Pages source differs. Its configuration was preserved.",flush=True)
        return
    build = run("gh","api","--method","POST",f"repos/{repo}/pages/builds",check=False)
    status = {"status":"build_requested" if build.returncode==0 else "owner_action_required","url":pages.get("html_url"),"source_commit":sha}
    Path("build/hosting.json").write_text(json.dumps(status),encoding="utf-8")
    print("PAGES_STATUS "+json.dumps(status),flush=True)
    if build.returncode:
        print(build.stderr,flush=True)

if __name__=="__main__":
    main()
