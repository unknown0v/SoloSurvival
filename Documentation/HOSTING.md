# Browser hosting with no engine installation

The release ZIP is a complete Godot WebAssembly game, not a website mockup. It needs an HTTP(S) host. WebGL 2 and WebAssembly are required; no game account or networking infrastructure is used.

The prepared `Deploy validated Web preview to itch.io` workflow downloads an existing validated release and uploads its HTML5 channel. It does not rebuild or run on the owner's laptop. After this workflow reaches the repository's default branch, it can be manually dispatched with the exact preview release tag.

Unavoidable account setup:
1. The itch.io owner creates/authorizes the intended game page.
2. Set GitHub Actions repository variable `ITCHIO_TARGET` to the exact authorized `username/game`.
3. Add `ITCHIO_API_KEY` through GitHub Actions Secrets. Never commit the key or paste it in chat.
4. After the first upload, the owner sets the itch.io page kind to HTML and marks the HTML5 channel playable in the browser.

The workflow uses official butler 15.24.0 from itch.io's documented broth service. This deployment workflow is prepared but has not been run or account-authorized. It does not claim a hosted URL exists. It checks the ZIP extraction paths and itch.io limits: 1,000 files, 240-character paths, under 500 MB total unpacked and under 200 MB per file.

The validated cloud pipeline also prepares a dedicated generated gh-pages branch with an ownership marker. It attempts free GitHub Pages activation using the workflow token. If GitHub denies that setting, the repository owner must enable Settings > Pages > Deploy from a branch > gh-pages / (root). Existing foreign branches and Pages sources are preserved. A live URL is reported only after the host responds; pipeline preparation alone does not establish that hosting is enabled. There is no need to buy hosting, enable Codespaces or install a local server to develop.

https://itch.io/docs/creators/html5  
https://itch.io/docs/butler/installing.html  
https://itch.io/docs/butler/pushing.html  
https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site
