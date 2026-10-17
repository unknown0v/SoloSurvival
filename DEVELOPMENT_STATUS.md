# SoloSurvival development status

Updated 2026-10-17 UTC. Branch `codex/godot-first-playable`; [draft PR #1](https://github.com/unknown0v/SoloSurvival/pull/1). Milestone 2 and several Phase A extensions are playable and verified. Version 1.0 is incomplete.

## Play, source and downloads
- [Play in the browser](https://unknown0v.github.io/SoloSurvival/)
- [Latest verified Web/Windows preview](https://github.com/unknown0v/SoloSurvival/releases/tag/preview-4f07a3bd5d20)
- Tested gameplay source: `4f07a3bd5d20a8b5bfc87d9553010209b958694a`, [cloud run 39048713145](https://github.com/unknown0v/SoloSurvival/actions/runs/39048713145).
- Earlier immutable M1/M2/progression releases remain available. Following documentation-only commits do not change the tested game payload.

## Integrated gameplay
M1 remains intact: one seeded 640 m island, first-person movement/sprint/crouch/jump/swim, gathering and durability, 36-slot inventory/six-slot bar, stack/split/drag/bulk transfer, timed crafting, health/hunger/thirst, day/night, death/recovery and saves.

Construction now includes plan/hammer, square foundations, full/half walls, window/door frames, floors, flat roofs, doors, walkable stairs/upper landings, storage, campfires, furnaces, cupboards, sleeping bags, beds and a basic workbench. Placement snaps/rotates and checks support, terrain, reach and obstruction. Twig/wood/stone/metal tiers have real costs, health, upgrades, damage, repair and collapse. Stairs need an open stairwell and support their adjacent upper landing.

Stations cook berries and smelt ore with wood, retaining ingredients when output is full. Connected cupboards pool upkeep materials every five simulated minutes after a 30-minute initial/migration grace; no offline decay. Exactly one bag/bed can bind respawn; capsule queries choose a clear adjacent spawn. A nearby workbench unlocks the metal pickaxe recipe. These are independent solo tuning, not Rust parity.

Movement now keeps commanded motion separate from collision velocity and uses floor snapping, fixing slow/stuck uphill traversal. Height queries match the existing terrain triangles without changing seed/vertex heights. Trees use regional batches with per-resource depletion/respawn ownership. Stable interaction IDs survive collider rebuilds.

## Executed validation
The linked run passed:
- Godot import/compilation and **145 headless assertions**: inventory/crafting conservation, malformed/future saves, backup recovery, support/collapse, upgrades/repair, processing, upkeep/material/separate-base behavior, migration, stable targets, real terrain/door/player collisions, fall damage, death/recovery, actual controller stair ascent and clear bed/bag respawn.
- **Five JavaScript confirmation cases** for matching/stale data, timeout, cancellation and denied storage. These simulated failure cases complement real browser persistence checks.
- Web/Windows exports, ZIP/license notices and itch.io size/path checks.
- Full exported-browser Chromium input: gathering/depleting a real tree, movement/collision, inventory, save import, plan/hammer crafting, seven-piece building including walls/roof/door, door operation/upgrade/damage/repair, storage, cooking/smelting, cupboard contents, bound-bag persistence, workbench tool crafting, half walls/windows/stairs, walking onto an upper landing and durable reloads.
- Public Pages source-manifest **and compiled-payload SHA** verification, then actual hosted core gameplay, building/door/repair/storage and save/reload checks. The hosted repeat intentionally skips the full processing/progression/extended-geometry suite already run against the exported payload.
- Browser fixtures supplied valid M1/M2 inventory through the normal file-picker UI; no mutable test command bridge exists. This is not the complete gather-to-endgame human walkthrough.

Browser snapshots used 960×540 Chromium/SwiftShader: latest startup/gathering samples were 5–7 FPS and 66 draw calls. Earlier runs ranged 1–4 FPS. These variable samples do not prove a reliable speed improvement or suitable-hardware 60 FPS. Pre-batching draw counts, CPU time, peak family memory, hardware GPU and 1080p performance were not measured.

## Saves and builds
Same historical save path `user://island-v1.json`; read schemas 1–4, write 4. Core progress, building health/tier, inventories, processing, upkeep and spawn binding persist. Integrity envelopes, backups, rejected-file preservation and future-version write blocking remain. Browser success waits for exact IndexedDB readback; wait for the confirmation before reloading and keep downloaded backups.

Observed ZIP sizes: Web 10,339,440 bytes, Windows 38,201,100 bytes. Windows is unsigned; it has **not** been executed at runtime. No human playtest, Firefox/Safari or real-device benchmark was performed. Browser UI drag/drop/splitting and every movement mode are not yet fully driven graphically.

## Remaining work and constraints
Triangle foundations/floors, practical double doors, armored tier, locks and defensive deployables remain Phase A gaps. Equipment, bleeding/temperature/radiation, dropped items, weapons/ammo/combat, wildlife/NPCs, meaningful monuments/loot, research/recycling/advanced progression and final art/audio/UI remain roadmap work. Current meshes/materials are simplified procedural placeholders.

Nonempty affected containers block destruction, including a decay collapse, rather than lose stored items. Persistent debris/drop ownership is needed before NPC base destruction. There is no upkeep offline, no demolition refund, and at most 256 pieces/four upper levels. No multiplayer/accounts/server infrastructure.

## Continuation and account state
No account/tool authorization blocker. GitHub write access works; no credential refresh is needed. Pages is enabled. All source/build/test operations were remote; no laptop tools were installed or executed. Only free public standard runners, Pages and Releases were used; no paid infrastructure provisioned. Optional itch.io workflow is prepared but unconfigured.

Resume by inspecting this branch's actual head and pinned run, then implement triangle pose/geometry support and remaining Phase A dependencies. Follow AGENTS.md and ROADMAP.md, preserve saves/releases and keep the PR draft. No background task or scheduler is configured after this session.
