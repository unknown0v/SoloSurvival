# SoloSurvival

A genuine single-player 3D survival game built with Godot 4 and GDScript. One deterministic island, offline gameplay and saves on your device. Independent original code and procedural assets; no proprietary Rust code or content.

Development branch: [codex/godot-first-playable](https://github.com/unknown0v/SoloSurvival/tree/codex/godot-first-playable). This is the first milestone, not a finished Rust recreation.

## Play

Validated Web and unsigned Windows ZIPs are published to [GitHub Releases](https://github.com/unknown0v/SoloSurvival/releases) after the cloud pipeline passes. If no preview release exists, no build has passed all checks yet.

The Web ZIP contains the actual Godot WebAssembly game. It must be served over HTTP(S), such as an itch.io HTML5 project; opening index.html directly from disk does not work. No engine installation is needed to play a hosted Web build. Windows ZIPs run normally after extraction; the native build is unsigned and not independently tested on Windows yet.

## Controls

| Action | Input |
|---|---|
| Start / resume | Enter or Embark |
| Look / move | Mouse / WASD |
| Sprint / crouch | Shift / Ctrl |
| Jump / swim upward | Space |
| Gather / use selected consumable | Left mouse |
| Harvest hemp or berries / drink river water / recover belongings | E |
| Hotbar | 1–6 / mouse wheel |
| Inventory and crafting | Tab |
| Pause | Esc |
| Save | F5 |
| Move items / half stack / split | Drag / Shift-drag / right click |

Begin with a rock and torch. Strike nearby trees and pale stone nodes, harvest hemp, then craft a hatchet or pickaxe. Consume berries and water from your hotbar or inventory. Crafted tools improve gathering yields. Keep food, water and health above zero. A death container retains belongings at your last position.

## Saves

Autosave runs every 30 simulated seconds; pause, F5 and quit also save. The island seed, location, inventory, crafting queue, health/food/water, clock, resource depletion and death containers persist. Time does not advance while the game is paused or closed.

Web saves use Godot's browser filesystem backed by IndexedDB. Private browsing, denied storage, iframe restrictions, changing the hosting origin or clearing site data can lose saves. Download and retain a JSON backup. A save on one browser/device is not a cloud save. Unknown future save formats and invalid files are preserved instead of silently overwritten.

## Cloud development, validation and builds

No local tool installation is required or performed. GitHub Actions uses a standard Ubuntu runner only for public repositories and installs checksum-pinned official Godot 4.7.2 binaries into that ephemeral runner. The workflow:

1. Imports and compiles Godot scripts.
2. Runs inventory, crafting, corruption/recovery tests and the actual 3D scene headlessly.
3. Exports Compatibility Web (single-threaded WebGL 2) and Windows x64.
4. Checks itch.io's HTML5 file count, path and unpacked-size constraints.
5. Runs Chromium using software WebGL, exercising startup, gathering, movement, collision and browser save/reload.
6. Publishes validated preview ZIPs and a smoke-test screenshot as GitHub release assets.

No paid runners, caches or Actions artifact uploads are configured. Standard runners for public repositories are free; GitHub releases have no total storage/bandwidth quota. This design does not change the owner's billing settings or account-wide usage. Workflows skip execution if the repository becomes private.

An automated browser smoke test is not a human playtest or a laptop GPU performance measurement. See [DEVELOPMENT_STATUS.md](DEVELOPMENT_STATUS.md) for actual results and remaining features.

## Architecture

`scripts/core/` owns item contracts, inventory, crafting, deterministic world height and save validation. `scripts/world/` owns procedural rendering, resources and audio. `player.gd` owns physical movement and camera input. `game.gd` orchestrates survival state and persistence; `scripts/ui/` presents it. The scene is generated programmatically from `scenes/island.tscn`; no manual editor wiring is required.

Web Compatibility rendering is the initial quality target. High-quality native rendering, construction, combat, wildlife, monuments, processing and advanced progression are later milestones. Visual parity with Rust is not claimed.

## Sources and licenses

Project code and procedural content: MIT, see [LICENSE](LICENSE). Godot: MIT; see [Documentation/THIRD_PARTY.md](Documentation/THIRD_PARTY.md). No asset-store packs, external fonts, paid services or runtime accounts are required.

Toolchain release: https://github.com/godotengine/godot-builds/releases/tag/4.7.2-stable  
Web constraints: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html  
GitHub runner billing: https://docs.github.com/en/billing/concepts/product-billing/github-actions  
Release limits: https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases  
itch.io HTML5 limits: https://itch.io/docs/creators/html5
