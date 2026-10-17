# Third-party notices

Godot Engine and its official export templates are used under the MIT license. Godot's compiled engine includes third-party components and its built-in font. Their required notices are maintained by the Godot project:

- https://godotengine.org/license/
- https://github.com/godotengine/godot/blob/4.7.2-stable/LICENSE.txt
- https://github.com/godotengine/godot/blob/4.7.2-stable/COPYRIGHT.txt

Cloud exports copy the exact engine LICENSE.txt and COPYRIGHT.txt into each downloadable bundle. These files are fetched from the pinned official engine tag during export. Original SoloSurvival meshes, colors, procedural textures, sounds and game scripts contain no Rust assets.

Playwright 1.56.1 (Apache-2.0) and Chromium are cloud test dependencies only. They are not redistributed in the game or installed on the owner's computer. GitHub Actions checkout is pinned to a commit. Official Godot archive SHA-256 values are pinned in tools/setup_godot.py from the GitHub release metadata.
