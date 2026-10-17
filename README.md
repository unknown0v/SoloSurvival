# SoloSurvival

An independent single-player Godot 4.7.2 / GDScript survival game on one persistent 3D island. Compatibility Web renderer and standalone offline Windows export. Original procedural art; an early playable game, not Rust parity or a finished 1.0 release.

**[Play in your browser](https://unknown0v.github.io/SoloSurvival/)** · [Downloads](https://github.com/unknown0v/SoloSurvival/releases) · [Draft PR](https://github.com/unknown0v/SoloSurvival/pull/1)

## Play

Enter starts/resumes. WASD moves; mouse looks; Shift sprints; Ctrl crouches; Space jumps/swims. Left click gathers with a selected rock/tool or uses consumables. E harvests plants, drinks river water, recovers belongings, opens containers and toggles doors. 1–6 selects the hotbar. Tab opens inventory/crafting; Escape pauses; F5 saves.

Craft a building plan and hammer in inventory. Press B to build; 1–9 chooses foundation, wall, floor, roof, frame, door, storage, campfire or furnace. R rotates, left click places a green preview. Foundations need dry/flat terrain; upper floors/roofs need walls. Aim at the supporting piece to choose its level. Press B to put the plan away.

Select the hammer: left click repairs, U upgrades, X dismantles. Costs are charged to inventory; removing supports collapses unsupported pieces. Empty every affected container first. No demolition refund. Station slots accept drag/drop and bulk transfers; start/stop processing in their panel. Campfires cook two berries with one wood into a ration; furnaces smelt two ore with one wood into metal.

## Persistence

The existing save path remains `user://island-v1.json`. Schema 1 loads unchanged; schema 2 adds structures and station contents/state. Saves include integrity checks, backup recovery and future-version protection. Browser save messages distinguish staged writes from confirmed IndexedDB persistence: wait for “Saved to browser storage” before reloading. Storage can still be unavailable/cleared by the browser; use Download Save Backup. Restore imports a validated JSON file and preserves existing saves.

## Cloud development

No Godot/tool installation on the owner's laptop. Public standard GitHub Actions runners install checksum-pinned official engine/templates, compile/import, run regressions, export Web/Windows and drive Chromium with software WebGL. Only validated branch builds publish immutable releases and a generated Pages branch. Optional itch.io deployment uses secrets and remains unconfigured. No paid infrastructure is provisioned.

[Project instructions](AGENTS.md) · [Roadmap](ROADMAP.md) · [Development status](DEVELOPMENT_STATUS.md) · [Parity report](RUST_PARITY.md) · [Asset licenses](ASSET_LICENSES.md) · [Release gates](RELEASE_CHECKLIST.md) · [Acceptance record](Documentation/ACCEPTANCE.md)

No native Windows runtime, human playtest, cross-browser or suitable-hardware 60 FPS claim is made. Construction extensions/upkeep, equipment/hazards, weapons/combat, wildlife/NPCs, monuments/research and final art/audio/UI remain roadmap work.
