# Independent gameplay comparison

No Rust binaries, proprietary assets, source or protected data were copied/analyzed. No direct reference gameplay timing study has yet been performed; comparisons below are broad design goals, not verified parity. Future entries must cite observed public gameplay or official documentation, observation date and measurable differences.

| System | SoloSurvival observed baseline / implementation | Difference / next verification |
|---|---|---|
| World | One deterministic 640 m island; original procedural art | Smaller, simplified terrain/assets; not Rust visuals |
| Controls | Mouse look, walking/sprint/crouch/jump/swim | Independent speeds/tuning; no measured Rust camera/movement match |
| Gathering/crafting | Rock/tools, stacks, six-slot bar, timed reserved recipes | Limited item set, independent yields/costs/timing |
| Survival | Health, food/water, fall/drowning, death/recovery | Temperature, bleeding, radiation and equipment still future |
| Construction | M2 source adds 3 m square sockets, tiers/support/repair/damage | Cloud tests pending; no triangle/window/stair/decay/upkeep/armored implementation yet |
| Processing | M2 source adds storage, berries cooking and ore smelting | Cloud tests pending; simplified fuel batches, no hunting/meat/bench progression yet |
| Combat/PvE | No integrated weapons/AI/monuments | All required before 1.0 |
| Persistence | Baseline browser save/reload verified | M2 schema migration and building persistence under validation |
| Native | Windows x64 export produced | Native Windows runtime not verified |

Never replace unmeasured comparisons with claims of Rust parity. Refresh entries after each validated increment.

## Documented references inspected 2026-10-17

[Facepunch tool cupboard, decay and building privilege](https://wiki.facepunch.com/rust/the_tool_cupboard) documents upkeep preventing building decay. This informs planned single-player upkeep; multiplayer building privileges are outside scope. No numerical timing or stability parity is established by this reference, and SoloSurvival upkeep is not yet implemented.
