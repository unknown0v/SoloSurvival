# Development status

Branch: `codex/godot-first-playable`. Source and all engine work are remote; nothing is installed on the owner's laptop. $0 additional spending is required.

## First milestone implementation
- One deterministic 640 m island with hills, beaches, forests, desert and snowy highlands; a fresh-water river and ocean.
- First-person movement, mouse look, sprint, collision-aware crouch, jump, swim, fall damage and drowning.
- Starting rock and torch; harvest wood, stone, metal ore, hemp and berries; depleted resources respawn after simulated time.
- 36 inventory slots, six hotbar slots, stacking, drag/drop, half transfer, splitting, durability and item use.
- Queued crafting of hatchet, pickaxe, bandages and torch; safe refunds and full-inventory handling.
- Health, hunger, thirst, consumables, death, persistent corpse containers and shoreline respawn.
- Thirty-minute day/night cycle, dynamic light/shadows, fog, water, procedural textures, tree distance LOD and first-person held tools.
- Local save/load, autosave, integrity validation, backup recovery, malformed/future-save protection and downloadable Web save backups.
- Original procedural meshes, materials and impact audio; no proprietary Rust assets or code.

## Verification
Cloud run [39040365174](https://github.com/unknown0v/SoloSurvival/actions/runs/39040365174) passed engine compilation, 43 headless assertions and actual Chromium software-WebGL gameplay checks (startup, gathering, movement, terrain collision, local save and browser reload). The real scene generated 232 resource nodes. Web and Windows exports succeeded and [preview-9346b2628bbc](https://github.com/unknown0v/SoloSurvival/releases/tag/preview-9346b2628bbc) was published. Web bundle: 11 files, 39,997,403 bytes unpacked, approximately 10.3 MB compressed; Windows ZIP approximately 38.2 MB.

This commit adds stronger death/recovery and inventory-menu checks plus capture-safe browser input. These added checks are pending its CI run. Earlier headless exits reported two ObjectDB instances; verbose diagnostics are enabled to identify the remaining cleanup. No human playtest or native Windows runtime test has occurred. Chromium software-rendered frame rates were 1–18 FPS during cold startup and smoke execution; these are cloud software-renderer observations, not laptop/GPU performance claims.

Validated Web files are on the owned generated gh-pages branch. Automatic Pages configuration returned HTTP 403; repository owner action is required at Settings > Pages > Deploy from a branch > gh-pages / (root). The connected collaborator can publish source and releases; refreshing Git credentials is not required.

## Fidelity gaps and priorities
This is a first milestone, not a finished Rust recreation. Visuals are procedural and simplified. Construction, repair/upkeep, processing, weapons, armor, wildlife, enemy AI, monuments, loot, weather, advanced progression, animations and native quality upgrades remain. No human playtest, laptop performance measurement or real-provider REA analysis has occurred. There is no network gameplay or game server.

Next: compile and fix errors in cloud CI; verify collision, resource gathering, inventory/crafting, persistence and Web startup; export Web and Windows; open a draft PR with actual evidence.
