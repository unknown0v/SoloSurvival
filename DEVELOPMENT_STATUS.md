# Development status — Milestone 2/rendering verified; base progression active

Updated 2026-10-17 UTC. Branch `codex/godot-first-playable`, [draft PR #1](https://github.com/unknown0v/SoloSurvival/pull/1). Continue autonomously through ROADMAP.md; no next-phase approval is needed.

## Latest verified playable state

[Play](https://unknown0v.github.io/SoloSurvival/) · [M2 Web/Windows downloads](https://github.com/unknown0v/SoloSurvival/releases/tag/preview-b30937aefd4b) · [Preserved M1 release](https://github.com/unknown0v/SoloSurvival/releases/tag/preview-8fc739d2a557)

Source `b30937aefd4b0702c036603df3eb4e8af5471325`, [cloud run 39044434999](https://github.com/unknown0v/SoloSurvival/actions/runs/39044434999), passed compilation/import, **95 headless assertions**, Web/Windows exports, package/license/itch-size checks, and full Chromium software-WebGL interactions on both the exported build and actual Pages URL. Both emitted BROWSER_SMOKE_PASS, CONSTRUCTION_BROWSER_PASS and PROCESSING_BROWSER_PASS.

Actual browser inputs imported a schema-1 fixture containing only M1 resources/items, crafted the plan/hammer, placed a foundation/frame/door, opened/closed/upgraded the door, placed storage, deposited contents, saved/reloaded, dismantled empty deployables, cooked berries, smelted ore, and restored station contents/state. This is fixture-assisted integration coverage, not the full gather-to-endgame human acceptance walkthrough.

## Integrated features

All M1 systems remain: one seeded 640 m island, first-person movement/crouch/jump/swim/fall/drowning, resources/tool durability, 36-slot inventory and six-slot hotbar, crafting queue, health/food/water, day/night, death containers/respawn/recovery and saves.

M2 adds building plan and hammer, square foundations/walls/floors/flat roofs/frames/doors, 3 m snapping, rotation, green/red previews, reach/terrain/player/resource/structure clearance, twig/wood/stone/metal tiers, costs, upgrade/repair/damage, support propagation and collapse. Storage and wood-fueled cooking/smelting persist inventory, active flag and progress. Nonempty affected containers block destruction to preserve items; demolition has no refund. Limit 256 pieces/four upper levels.

Terrain height queries now interpolate the exact existing 4 m collision triangles; original vertex heights/seed are unchanged. Existing save path remains `user://island-v1.json`: read schemas 1/2, write 2; integrity, backups, rejected-file preservation and future-version blocking remain. Browser saves report success only after read-only IndexedDB confirmation of the exact saved file, fixing an observed furnace reload reverting to an older generation.

## Rendering follow-up verified

Source `be72860fe4ef25f6171bd553bfa9356cd394a677`, [run 39045492002](https://github.com/unknown0v/SoloSurvival/actions/runs/39045492002), passed 100 headless assertions, five JavaScript confirmation cases, both exports and full exported/public browser checks. Actual browser rendering verified full tree depletion; construction now included walls/roof, seven saved pieces, door operation/upgrading and storage. Cooking/smelting and their durable reloads also passed in both environments.

The equivalent software-WebGL startup/gathering snapshots showed 66 draw calls and 1–4 FPS after batching, against roughly 2–3 FPS before. These variable snapshots do not establish a reliable speed improvement. CPU time, peak process-family memory and hardware-GPU performance were not measured.

## Current increment, awaiting validation

Cupboard upkeep/decay, sleeping-bag binding/safe respawn, workbench-gated metal pickaxe and schema-3 maintenance data are implemented for the next cloud run. Read older schemas 1/2 through the format owner, retaining existing inventory/world data and applying defaults for new fields. Upkeep starts after a 30 simulated-minute new/migration grace, charges per material every five simulated minutes and does not advance offline. Connected cupboards pool material; nonempty collapse protection remains. Browser tests add schema-2 fixture import and real cupboard/bag/workbench/tool operations; the hosted repeat is reduced to core gameplay and construction/storage reload to avoid duplicating the full processing/progression run.

### Prior rendering approach

Forest rendering moves from individual tree meshes to regional MultiMesh batches with per-resource depletion/respawn ownership. The superseded tree-rendering path is removed. The next CI adds batch lifecycle checks, readback error/cancellation tests and browser wall/roof placement. A placement review also preserves the explicitly selected socket's base height.

Before this increment, equivalent 960×540 software-WebGL startup/gathering snapshots were roughly 1–3 FPS. New draw-call/FPS telemetry will record observations; no performance improvement or suitable-hardware 60 FPS claim is made yet. CPU time, peak family memory and real-device GPU performance remain unmeasured.

## Remaining scope and limits

Phase A still needs triangle pieces, half walls, window frames, stairs, practical double doors, armored tier, beds, locks and defenses; cupboard upkeep, sleeping bags and a basic workbench are under current validation. Equipment/status hazards, weapons/combat, wildlife/NPCs, monuments/loot, research/progression, final art/audio/UI and performance work remain. Follow ROADMAP.md in dependency order.

No human playtest, native Windows runtime verification, Firefox/Safari or hardware-GPU benchmark. Windows is unsigned. Browser UI drag/drop and complete movement modes are not yet fully driven graphically. Campfire cooking currently uses gathered berries; hunting/meat comes later. Stations/buildings use simplified original geometry. No Rust parity or 1.0 claim.

All development/build execution is remote. Free public standard Linux runners, Pages and release hosting only; no paid infrastructure or local installations/execution. Same-repository duplicate PR builds are skipped; trusted branch pushes perform validation/publication. Optional itch.io workflow remains unconfigured.

## Continuation

Inspect current branch head and CI before changing anything. Fix active-increment regressions first; preserve the verified M2 release above. Update this file and PR with exact next verified source/run. Then continue Phase A extensions and survival/progression without asking which ordinary feature is next. See AGENTS.md and RELEASE_CHECKLIST.md. No background execution is configured after a session ends.

## Base-progression checkpoint verified

Source `46232e96790ab03daf41d79b22b53e32bf494b33`, [run 39046908209](https://github.com/unknown0v/SoloSurvival/actions/runs/39046908209), passed 126 headless assertions, five JavaScript confirmation tests, both exports and complete exported-browser cooking/smelting/upkeep-storage/bag/workbench-tool integration. The public Pages repeat passed core gameplay and seven-piece construction, repair and storage reload; it intentionally did not repeat processing/progression. [Preserved verified release](https://github.com/unknown0v/SoloSurvival/releases/tag/preview-46232e96790a).

Active unverified follow-up: half walls, window frames, walkable stairs with adjacent upper landings and open stairwells, beds sharing the bound-spawn owner, safe spawn offsets, schema-4 migration and compiled source identity. The next cloud suite tests actual controller stair ascent and browser placement/ascent/reload. No completion or successful graphical test is claimed before that run finishes.
