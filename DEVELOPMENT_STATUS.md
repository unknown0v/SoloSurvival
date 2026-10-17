# Development status — first playable milestone

Updated 2026-10-17 UTC. Source of truth: `codex/godot-first-playable`, [draft PR #1](https://github.com/unknown0v/SoloSurvival/pull/1). All development and engine execution were remote; no tools were installed or run on the owner's laptop.

## Play and downloads

- Browser: https://unknown0v.github.io/SoloSurvival/
- [Validated Web and Windows builds](https://github.com/unknown0v/SoloSurvival/releases).
- Enter or click Embark, move with WASD, look with the mouse, select rock with 1, strike trees/stone with left click, gather plants with E, open inventory/crafting with Tab.
- F5 saves; the pause/title menu downloads and restores validated JSON backups.

## Completed and integrated

- Godot 4.7.2 + GDScript, Compatibility renderer, single-threaded Web and standalone Windows x64 presets.
- One deterministic 640 m island with hills, beaches, forests, desert-colored terrain, snowy highlands, ocean and a fresh-water river.
- First-person movement, sprint, collision-aware crouch, jump, swimming, fall damage and drowning.
- 232 generated resource nodes in the measured seed: trees, stone, metal ore, hemp and berries; depleted nodes respawn after simulated time.
- Starting rock/torch, held-tool visuals, durability, 36-slot inventory, six-slot hotbar, stacking, drag/drop, half transfer and splitting.
- Crafting queue for hatchet, pickaxe, bandage and torch, reserved ingredients, capacity-safe delivery and atomic refunds.
- Health, hunger, thirst, consumables, death containers, shoreline respawn and recovery.
- Thirty-minute day/night cycle, fog, animated water, procedural materials/audio and tree distance LOD. Dynamic shadows default off on Web, on for native; the pause menu toggles them.
- Validated local save/load, 30-second autosave, integrity checks, backup recovery and preservation of malformed/future saves. No offline time advancement.
- Cloud CI, official checksum-pinned engine/templates, export checks, native bundle license notices, free GitHub release downloads and generated Pages publishing.
- Optional itch.io deployment workflow prepared; no itch.io credentials configured or deployment performed.

## Executed validation

[Cloud run 39041098312](https://github.com/unknown0v/SoloSurvival/actions/runs/39041098312), source commit `b1c6c624cfadcc16e39e4871fcdeede842b8737d`, passed:
- Godot script import/compilation.
- 49 headless assertions covering inventory limits/transfers/splits, crafting reservation/completion/refund, malformed saves, digest validation, backup recovery and future-save preservation.
- Production-scene generation, physics collision, gathering, tool wear, death/corpse persistence, respawn, recovery and live-world saving.
- Web and Windows exports, ZIP structure and itch.io size/path/file-count checks.
- Full Chromium on a cloud virtual display using software WebGL, at 960×540: startup, actual mouse-button gathering, keyboard movement, terrain collision, inventory open/close, save and reload.
- The same browser checks against the actual public Pages URL, after verifying its deployed source manifest. Both emitted BROWSER_SMOKE_PASS.
- The expanded verbose test run reported no ObjectDB leak warning.

The later documentation/publication-retry follow-up does not change game code. Its workflow results remain independently visible in the PR checks. Release assets are immutable per source commit; retries preserve an existing release only when its target commit matches.

Observed Web bundle: 11 files, about 40 MB unpacked / 10.3 MB ZIP; Windows ZIP about 38.2 MB. Cloud software-renderer frame rates ranged roughly 1–18 FPS during cold startup and checks. This does not establish laptop or hardware-GPU performance. CPU time, peak process-family memory and hardware 1080p performance were not measured.

## Known limitations and fidelity gaps

- No human playtest, native Windows runtime test, Firefox/Safari coverage or real-device GPU benchmark. Windows build is unsigned.
- Browser file-picker restoration and UI drag/drop have not been driven in the automated browser test; their data validation, inventory and transfer semantics are covered headlessly.
- Browser saves depend on this origin/browser's IndexedDB and can be lost if site data is cleared, private browsing is used, or storage is denied. Download backups. Windows is fully standalone; Web needs hosting for the initial load and has no guaranteed offline PWA cache.
- This is not Rust parity. Geometry, foliage, terrain detail, materials, camera feel, reach, movement tuning, recipes, yields, sounds and UI are independent approximations. No lawful Rust reference binaries/assets were analyzed.
- Construction/snapping, upgrades, upkeep, storage/workstations, cooking/smelting, weapons/ammunition, armor, temperature/bleeding/radiation, wildlife, enemy AI, monuments/loot, weather and advanced progression remain future milestones.
- Crafting continues in inventory and resumes after death; no offline simulation. Up to 32 persistent death containers; at capacity, carried belongings are retained rather than discarded.
- No multiplayer, dedicated server, matchmaking, runtime accounts or microtransactions.

## Next priorities

1. Review the playable loop and measure representative hardware performance; optimize render batching/LOD and controls.
2. Add integrated foundation/wall snapping, storage, campfire cooking, furnace processing and persistence tests.
3. Add weapon/combat and wildlife milestones, then monuments, loot and workbench progression.
4. Improve original or CC0 environment art, animation, sound and weather, with an asset/license ledger.
5. Verify the native Windows runtime and expand browser coverage before making quality/performance claims.

## Account and budget state

GitHub identity `sebsabyoussef20-rgb` has working write access; commits, branch publication and PR creation succeeded. No Git credential refresh is needed for this connection. The owner enabled Pages after automatic initial setup returned 403; subsequent publishing and hosted-game checks succeeded.

Public standard Ubuntu runners and free Pages/release hosting are used. Custom validation jobs do not use caches or upload Actions artifacts; GitHub's managed Pages deployment has its own deployment artifact. No paid runner, Codespace, hosting plan or other paid infrastructure was provisioned; account-wide billing settings were not changed.
