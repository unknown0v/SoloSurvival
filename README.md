# SoloSurvival

An independent single-player Godot 4.7.2 / GDScript survival game on one persistent 3D island. Compatibility Web renderer and standalone offline Windows export. Original procedural art; an early playable game, not Rust parity or a finished 1.0 release.

**[Play in your browser](https://unknown0v.github.io/SoloSurvival/)** · [Downloads](https://github.com/unknown0v/SoloSurvival/releases) · [Draft PR](https://github.com/unknown0v/SoloSurvival/pull/1)

## Play

Enter starts/resumes. WASD moves; mouse looks; Shift sprints; Ctrl crouches; Space jumps/swims. Left click gathers with a selected rock/tool or uses consumables. E harvests plants, drinks river water, recovers belongings, opens containers and toggles doors. 1–6 selects the hotbar. Tab opens inventory/crafting; Escape pauses; F5 saves.

Craft a building plan and hammer in inventory. Press B to build; 1–9 chooses foundation, wall, floor, roof, frame, door, storage, campfire or furnace. G cycles cupboard, sleeping bag, workbench, half wall, window frame, stairs and bed types; R rotates, left click places a green preview. Foundations need dry/flat terrain; upper floors/roofs need walls. Aim at the supporting piece to choose its level. Press B to put the plan away.

Select the hammer: left click repairs, U upgrades, X dismantles. Costs are charged to inventory; removing supports collapses unsupported pieces. Empty every affected container first. No demolition refund. Station slots accept drag/drop and bulk transfers; start/stop processing in their panel. Campfires cook two berries with one wood into a ration; furnaces smelt two ore with one wood into metal.

Cupboards hold material upkeep for connected bases, charged every five simulated minutes after a 30-minute new/migration grace. No offline decay. E binds a sleeping bag for safe respawning, or opens a workbench that unlocks the metal pickaxe recipe within six metres. Construction, upkeep, bound bag/bed respawn, workbench crafting and extended wall/window/stair systems are integrated with declared validation. See DEVELOPMENT_STATUS.md for exact sources/builds.

Stairs lead to the adjacent upper floor in their facing direction. Aim at stairs and select floor to snap a landing; leave the tile above stairs open as a stairwell. Beds and bags share one bound respawn, with nearby collision checks before spawning.

## Persistence

The existing save path remains `user://island-v1.json`. Schemas 1–3 remain readable; schema 4 retains upkeep/bound spawns and adds the extended piece catalog. Saves include integrity checks, backup recovery and future-version protection. Browser save messages distinguish staged writes from confirmed IndexedDB persistence: wait for “Saved to browser storage” before reloading. Storage can still be unavailable/cleared by the browser; use Download Save Backup. Restore imports a validated JSON file and preserves existing saves.

## Cloud development

No Godot/tool installation on the owner's laptop. Public standard GitHub Actions runners install checksum-pinned official engine/templates, compile/import, run regressions, export Web/Windows and drive Chromium with software WebGL. Only validated branch builds publish immutable releases and a generated Pages branch. Optional itch.io deployment uses secrets and remains unconfigured. No paid infrastructure is provisioned.

[Project instructions](AGENTS.md) · [Roadmap](ROADMAP.md) · [Development status](DEVELOPMENT_STATUS.md) · [Parity report](RUST_PARITY.md) · [Asset licenses](ASSET_LICENSES.md) · [Release gates](RELEASE_CHECKLIST.md) · [Acceptance record](Documentation/ACCEPTANCE.md)

No native Windows runtime, human playtest, cross-browser or suitable-hardware 60 FPS claim is made. Construction extensions/upkeep, equipment/hazards, weapons/combat, wildlife/NPCs, monuments/research and final art/audio/UI remain roadmap work.
