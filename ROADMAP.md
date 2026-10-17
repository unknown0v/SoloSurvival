# SoloSurvival roadmap

The owner authorizes continuous development through version 1.0 during available execution. No milestone requires another ordinary approval. Read DEVELOPMENT_STATUS.md for actual progress; unchecked work is not implemented by this roadmap.

- [x] M1: persistent island, first-person controls, resources, inventory, basic crafting, survival, day/night, death, saves, Web/Windows cloud exports.
- [x] M2: validate square foundations/walls/floors/roofs/frames/doors, preview/snapping, tiers/repair/damage/support, storage, cooking and smelting.
- [ ] Phase A completion: triangle pieces, half walls, windows, stairs, practical double doors, armored tier, decay/cupboard upkeep, sleeping bags/beds, locks, workbenches and basic defenses.
- [ ] Phase B: bleeding, temperature/biome exposure, radiation, clothing/armor, food/water/healing balance and meaningful recovery.
- [ ] Phase C: equipment, quick transfers, dropped items, loot, bench-gated recipes, expanded item/recipe content and conservation regressions.
- [ ] Phase D: reusable damage/projectile/ammo/armor systems; spears/bows/crossbow, distinct firearms, reload/recoil/aim/durability/audio, game explosives.
- [ ] Phase E: deer/boar/wolf/bear finite-state AI, harvestable corpses, hostile patrol NPCs, detection/combat/loot/respawn and distance scheduling.
- [ ] Phase F: improve same seeded island, roads/paths/lake/cliffs and wildlife habitats; meaningful gas station, supermarket, harbor, military and industrial areas with hazards/loot.
- [ ] Phase G: workbench tiers, scrap, research/blueprints, recycling and risk/reward PvE progression.
- [ ] Phase H: replace procedural placeholders progressively, improve original/licensed terrain/vegetation/PBR/water/atmosphere/weather/animation.
- [ ] Phase I: original/licensed spatial ambience, footsteps, combat/building/station/UI audio.
- [ ] Phase J: new/continue/settings, configurable input/graphics/audio, equipment/loot/workbench/map/status/respawn UI.
- [ ] Phase K: persistence for every integrated system, migrations, autosave/manual save/import/export/corruption/backup regressions.
- [ ] Phase L: measure bottlenecks, batching/LOD/culling/AI scheduling; browser quality profile and suitable native enhancements.
- [ ] Phase M: complete gameplay acceptance walkthrough, regression fixes, browser validation, Windows runtime verification and human review.
- [ ] Phase N: only after RELEASE_CHECKLIST.md passes, tag 1.0.0 with source, offline Windows build, Web build, licenses, release notes and honest limitations.

Dependencies: construction → processing/benches → weapons/armor → wildlife/NPCs → monuments/progression. Survival, persistence, UI, assets and performance evolve with each playable increment. Preserve one island/seed and all validated releases.

M2 validation: source `b30937aefd4b0702c036603df3eb4e8af5471325`, [run 39044434999](https://github.com/unknown0v/SoloSurvival/actions/runs/39044434999), 95 headless assertions, both exports, exported/public browser construction and processing save/reload. Regional tree batching and fuller browser shelter checks are the active follow-up; this does not complete Phase A.

Rendering follow-up verified: source `be72860fe4ef25f6171bd553bfa9356cd394a677`, run 39045492002; 100 headless assertions, five confirmation cases and full exported/public browser building/processing reload. Active: cupboard upkeep, bound sleeping bag, basic workbench and metal tool; schema-3 migration and browser tests pending.
