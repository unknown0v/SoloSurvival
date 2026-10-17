# Independent gameplay comparison

No Rust source, proprietary assets or protected binary data were copied or analyzed. No direct gameplay timing study has been performed. The following are broad design comparisons, not verified parity. Future claims need dated observations and sources.

| System | Verified SoloSurvival behavior | Material differences / gaps |
|---|---|---|
| World | One deterministic 640 m 3D island, resources and day/night | Smaller/simplified terrain and procedural art; no monuments or populated PvE yet |
| Controls | Mouse look and movement; real physics tests include floor, fall, stairs and bed spawn | Independent speed/camera/swim tuning; no measured Rust movement match |
| Inventory/crafting | Six-slot hotbar, stacks, transfers, reserved/timed queue and bench-gated metal tool | Equipment, instance metadata, drops, weapons and research remain |
| Construction | Square sockets, full/half walls/windows, floors/roof, frame/door, stairs/landings, four material tiers, support/repair/damage | No triangles, armored tier, locks, practical double doors or defenses; independent costs/health/stability |
| Processing | Capacity-safe berry cooking and ore smelting, storage, persistent station state | No hunting/meat or advanced industrial chains yet |
| Upkeep | Connected cupboards pool material, material-specific protection, grace and simulated-time decay | Independent solo costs/rates; no offline decay; stored-item protection can prevent final collapse |
| Respawn | One bound bag/bed; collision queries choose a clear nearby point | Independent binding/placement rules and timing; no measured Rust cooldown parity |
| Survival | Health/food/water, fall/drowning, death/recovery | Bleeding, temperature, radiation, equipment/armor and fuller balance remain |
| Combat/PvE/progression | Gathering tools and base damage exist | Weapons, wildlife, NPCs, monuments/loot and advanced progression unimplemented |
| Persistence | Schemas 1–4, backup recovery, durable browser confirmation; actual reload checks | Windows runtime/cross-browser/human coverage still open |
| Graphics/audio | Original procedural geometry/materials/impact sound, batch rendering | Substantially below Rust visual/audio fidelity; major art/animation/weather/audio work remains |

Verified source `4f07a3bd5d20a8b5bfc87d9553010209b958694a`, [run 39048713145](https://github.com/unknown0v/SoloSurvival/actions/runs/39048713145). Exported and hosted browser coverage differ; see DEVELOPMENT_STATUS.md. No 1.0 or Rust-equivalence claim.

## Documented reference inspected 2026-10-17
[Facepunch: tool cupboard, decay and building privilege](https://wiki.facepunch.com/rust/the_tool_cupboard) documents connected-building upkeep and material-specific protection. SoloSurvival uses this as a qualitative design reference with independent solo tuning; multiplayer privilege is out of scope. That documentation does not establish numerical parity or measured live gameplay.
