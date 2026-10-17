# Development status — Milestone 2

Updated 2026-10-17 UTC. Building on the existing first playable at `8fc739d2a5578c8be109b596c52e3411f0aa148d`, preserving its history and immutable release assets. Development and validation execute remotely through GitHub tools and public standard cloud runners; no local tool execution or installation.

## Implemented, awaiting cloud verification

- Separate construction model and world adapter: building plan, foundation/wall/floor/roof/doorframe/door, 3 m sockets, previews, rotation, reach/terrain/player/resource/structure clearance.
- Twig, wood, stone and metal tiers; resource costs, health, repairs, damage, support propagation and collapse. Nonempty affected containers block dismantling/destruction rather than lose items.
- Persistent storage, campfire berry cooking and wood-fueled metal-ore smelting, start/stop, inventory transfer, capacity-safe processing and simulated-time progress.
- Save schema 2 at the existing save path, retaining version-1 loading and preserving future-version rejection, digest checks and backups.
- Crafting scroll panel, building guide, station inventory panel, repaired inventory-open jump handling and cached support display.
- Existing movement, harvesting, inventory, crafting, survival, death/recovery, day/night and browser save features retained.

## Verification

Implementation is not yet claimed tested. CI will compile scripts, run the existing 51 regression assertions plus new construction/migration/processing coverage, export Web/Windows and exercise browser interactions before publishing. The current public preview remains the last validated milestone until new checks succeed.

Existing validated baseline: [run 39041783852](https://github.com/unknown0v/SoloSurvival/actions/runs/39041783852), 51 assertions, local and public Chromium software-WebGL interaction checks and both exports. [Preserved release](https://github.com/unknown0v/SoloSurvival/releases/tag/preview-8fc739d2a557).

## Limits and remaining work

Independent simplified procedural visuals; no Rust parity claim. No human playtest, native Windows runtime verification, Firefox/Safari or hardware-GPU benchmark. Construction is capped at 256 pieces/four upper levels; no upkeep, offline processing or demolition refund. Campfire cooking initially uses gathered berries; hunting/meat comes with wildlife. No multiplayer/accounts/server infrastructure.

Combat, weapons, wildlife/NPCs, monuments/loot, weather and advanced progression remain future milestones. Free public Linux runners, Pages and release hosting only; no paid infrastructure provisioned. Optional itch.io workflow remains unconfigured.
