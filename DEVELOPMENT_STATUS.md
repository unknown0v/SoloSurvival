# Development status — Milestone 2 verified; rendering increment active

Updated 2026-10-17 UTC. Branch `codex/godot-first-playable`, [draft PR #1](https://github.com/unknown0v/SoloSurvival/pull/1). Continue autonomously through ROADMAP.md; no next-phase approval is needed.

## Latest verified playable state

[Play](https://unknown0v.github.io/SoloSurvival/) · [M2 Web/Windows downloads](https://github.com/unknown0v/SoloSurvival/releases/tag/preview-b30937aefd4b) · [Preserved M1 release](https://github.com/unknown0v/SoloSurvival/releases/tag/preview-8fc739d2a557)

Source `b30937aefd4b0702c036603df3eb4e8af5471325`, [cloud run 39044434999](https://github.com/unknown0v/SoloSurvival/actions/runs/39044434999), passed compilation/import, **95 headless assertions**, Web/Windows exports, package/license/itch-size checks, and full Chromium software-WebGL interactions on both the exported build and actual Pages URL. Both emitted BROWSER_SMOKE_PASS, CONSTRUCTION_BROWSER_PASS and PROCESSING_BROWSER_PASS.

Actual browser inputs imported a schema-1 fixture containing only M1 resources/items, crafted the plan/hammer, placed a foundation/frame/door, opened/closed/upgraded the door, placed storage, deposited contents, saved/reloaded, dismantled empty deployables, cooked berries, smelted ore, and restored station contents/state. This is fixture-assisted integration coverage, not the full gather-to-endgame human acceptance walkthrough.

## Integrated features

All M1 systems remain: one seeded 640 m island, first-person movement/crouch/jump/swim/fall/drowning, resources/tool durability, 36-slot inventory and six-slot hotbar, crafting queue, health/food/water, day/night, death containers/respawn/recovery and saves.

M2 adds building plan and hammer, square foundations/walls/floors/flat roofs/frames/doors, 3 m snapping, rotation, green/red previews, reach/terrain/player/resource/structure clearance, twig/wood/stone/metal tiers, costs, upgrade/repair/damage, support propagation and collapse. Storage and wood-fueled cooking/smelting persist inventory, active flag and progress. Nonempty affected containers block destruction to preserve items; demolition has no refund. Limit 256 pieces/four upper levels.

Terrain height queries now interpolate the exact existing 4 m collision triangles; original vertex heights/seed are unchanged. Existing save path remains `user://island-v1.json`: read schemas 1/2, write 2; integrity, backups, rejected-file preservation and future-version blocking remain. Browser saves report success only after read-only IndexedDB confirmation of the exact saved file, fixing an observed furnace reload reverting to an older generation.

## Current increment, not yet claimed validated

Forest rendering moves from individual tree meshes to regional MultiMesh batches with per-resource depletion/respawn ownership. The superseded tree-rendering path is removed. The next CI adds batch lifecycle checks, readback error/cancellation tests and browser wall/roof placement. A placement review also preserves the explicitly selected socket's base height.

Before this increment, equivalent 960×540 software-WebGL startup/gathering snapshots were roughly 1–3 FPS. New draw-call/FPS telemetry will record observations; no performance improvement or suitable-hardware 60 FPS claim is made yet. CPU time, peak family memory and real-device GPU performance remain unmeasured.

## Remaining scope and limits

Phase A still needs triangle pieces, half walls, window frames, stairs, practical double doors, armored tier, decay/cupboard upkeep, sleeping bags/beds, workbenches, locks and defenses. Equipment/status hazards, weapons/combat, wildlife/NPCs, monuments/loot, research/progression, final art/audio/UI and performance work remain. Follow ROADMAP.md in dependency order.

No human playtest, native Windows runtime verification, Firefox/Safari or hardware-GPU benchmark. Windows is unsigned. Browser UI drag/drop and complete movement modes are not yet fully driven graphically. Campfire cooking currently uses gathered berries; hunting/meat comes later. Stations/buildings use simplified original geometry. No Rust parity or 1.0 claim.

All development/build execution is remote. Free public standard Linux runners, Pages and release hosting only; no paid infrastructure or local installations/execution. Same-repository duplicate PR builds are skipped; trusted branch pushes perform validation/publication. Optional itch.io workflow remains unconfigured.

## Continuation

Inspect current branch head and CI before changing anything. Fix active-increment regressions first; preserve the verified M2 release above. Update this file and PR with exact next verified source/run. Then continue Phase A extensions and survival/progression without asking which ordinary feature is next. See AGENTS.md and RELEASE_CHECKLIST.md. No background execution is configured after a session ends.
