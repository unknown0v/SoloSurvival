# SoloSurvival roadmap to 1.0

The owner authorizes continuous development during available execution; ordinary next phases need no new approval. Exactly one human, one persistent island, Godot 4/GDScript, Web and offline Windows, $0 additional infrastructure. No prototype is to be labeled 1.0.

## Verified foundation
- [x] M1: island, first-person controls, resources, inventory/hotbar, basic crafting, survival, day/night, death/recovery, saves and cloud exports.
- [x] M2: plan, foundations/walls/floors/roofs/frames/doors, snapping/previews/rotation, tiers, repair/damage/support, storage, cooking and smelting.
- [x] Phase A extensions: half walls, window frames, stairs/upper landings, beds/bags, upkeep cupboards and basic workbench/metal tool.
- [x] Supporting work: terrain-surface agreement, stable target ownership, regional tree batches, durable browser save confirmation and schemas 1–4.
- Evidence: source `4f07a3bd5d20a8b5bfc87d9553010209b958694a`, [run 39048713145](https://github.com/unknown0v/SoloSurvival/actions/runs/39048713145), 145 Godot assertions, five JS cases, both exports, exported-browser integration and hosted core/construction/storage checks.

## Remaining phases
- [ ] A completion: triangle foundations/floors, practical double doors, armored tier, locks and basic defenses. Extend the pose contract without shifting saved square pieces. Item metadata/drop ownership precedes keys/locks and destructive loot.
- [ ] B survival: bleeding, cold/heat/biomes, radiation, recovery, clothing/armor and solo balance. Preserve existing fall/drowning/deprivation behavior.
- [ ] C inventory/crafting: equipment slots, instance metadata, quick transfer, dropped items/loot, expanded recipes and bench requirements; conservation and save regressions.
- [ ] D combat: reusable damage/projectile/armor/ammo, spears, bow/crossbow, distinct primitive firearm/pistol/revolver/shotgun/rifle/automatic/game explosives; equip/aim/reload/recoil/durability/animation/effects/audio.
- [ ] E AI: deer/boar/wolf/bear states, hunting/harvestable corpses; hostile patrol NPC vision/hearing/pursuit/combat/loot/respawn and distance scheduling.
- [ ] F island content: preserve same seed/map; improve biomes, cliffs/lake/roads/paths/habitats; meaningful gas station, supermarket, harbor, military and industrial locations with hazards and loot.
- [ ] G progression: workbench tiers, scrap, research/blueprints, recycling, advanced gear and risk/reward PvE objectives.
- [ ] H visuals: replace major placeholder geometry progressively, improve terrain/vegetation/PBR/water/sky/clouds/weather/lighting/animation; original/licensed assets with ledger.
- [ ] I audio: spatial forest/ocean/river/wind/rain/night, footsteps/surfaces, gathering, handling/combat, animals/NPCs, building/stations/UI.
- [ ] J UI: functional new/continue/settings, sensitivity/controls/graphics/audio, equipment/loot/workbench/map/status/respawn interfaces.
- [ ] K persistence: migrate and save every integrated system; autosave/manual/import/export/integrity/recovery; never silently reset.
- [ ] L performance: measure actual bottlenecks, improve culling/LOD/batching/AI/pooling/load/memory; low browser and suitable enhanced native profiles. Hardware 1080p/60 FPS target remains unverified.
- [ ] M acceptance: execute the complete 30-step walkthrough, regressions and browser coverage, native Windows runtime and offline testing, human review and major bug fixes.
- [ ] N release: only after RELEASE_CHECKLIST.md passes, publish 1.0.0 source/builds/notices/release notes and known limitations.

Dependency order: construction/processing → equipment/ownership/benches → combat → AI → monuments/research; persistence, UI, assets and performance evolve with each tested increment. Keep a playable preview and immutable releases throughout.
