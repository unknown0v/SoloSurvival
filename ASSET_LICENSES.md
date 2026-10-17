# Asset and dependency licenses

| Content | Exact source / provenance | License / attribution |
|---|---|---|
| Terrain, trees/rocks/foliage, construction/deployable/tool meshes, shaders, procedural textures and impact audio | Original SoloSurvival code in scripts/, shaders/ and scenes/ | Project MIT license; no external game art/audio |
| Godot 4.7.2 engine and official export templates | https://github.com/godotengine/godot/releases/tag/4.7.2-stable | MIT and bundled third-party notices |
| Godot bundled libraries/font and engine assets | Exact official distribution | Exported Godot COPYRIGHT.txt and LICENSE.txt |
| Cloud Playwright 1.56.1 | https://github.com/microsoft/playwright | Apache-2.0; development only, not shipped |
| Cloud Chromium | Playwright browser tooling | Development only; no browser executable shipped |
| Pinned checkout action | .github/workflows/godot.yml commit reference | CI tooling only |

Exports include exact [engine LICENSE](https://github.com/godotengine/godot/blob/4.7.2-stable/LICENSE.txt), [COPYRIGHT notices](https://github.com/godotengine/godot/blob/4.7.2-stable/COPYRIGHT.txt) and the project MIT license. See Documentation/THIRD_PARTY.md.

No externally sourced game models, textures, sounds or animations have been added. No Rust proprietary assets are included. Future assets require creator, exact source, license/version, modifications, files and attribution before redistribution; prefer CC0 when suitable. “Free download” alone is insufficient.
