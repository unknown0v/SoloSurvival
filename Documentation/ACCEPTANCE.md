# Complete-game acceptance record

Run on the actual integrated build before 1.0. Record source SHA, platform, input method, steps, outcome, evidence and defects. Headless tests do not substitute for graphical walkthroughs; browser tests do not establish Windows runtime behavior.

| # | Player action | Current evidence / remaining acceptance |
|---|---|---|
| 1 | Start a new world | Fresh-browser startup automated; explicit new-game UI pending |
| 2 | Spawn on the island | M1 browser verified |
| 3 | Walk, sprint, crouch, jump, swim | Walking/collision browser verified; full graphical movement walkthrough pending |
| 4 | Gather wood and stone | Wood browser verified; tool gathering production path headless verified |
| 5 | Craft tools | Domain timing/cost tests; expanded graphical recipes pending |
| 6 | Manage inventory | Toggle/save browser, stacking/splitting/transfers headless; drag/drop browser pending |
| 7 | Hunt animals | Not implemented |
| 8 | Collect food and water | Plants/river and consumables implemented; full walkthrough pending |
| 9 | Build foundations | M2 real-scene tests pass; browser acceptance in progress |
| 10 | Place walls and roofs | M2 support/collision/domain tests; browser acceptance in progress |
| 11 | Add doors | M2 real-scene operation/obstruction tests pass; browser acceptance in progress |
| 12 | Upgrade structures | M2 material-tier tests pass; browser acceptance in progress |
| 13 | Repair structures | M2 damage/material/health tests pass; graphical interaction pending |
| 14 | Place storage | M2 implementation and contents validation; browser acceptance in progress |
| 15 | Craft/place campfire | M2 resource-cost placement; browser acceptance in progress |
| 16 | Cook food | Berries cooking model tests pass; browser acceptance in progress; hunting/meat pending |
| 17 | Craft/place furnace | M2 resource-cost placement; browser acceptance in progress |
| 18 | Smelt ore | Ore/fuel/output model tests pass; browser acceptance in progress |
| 19 | Craft weapons | Not implemented |
| 20 | Explore monuments | Not implemented |
| 21 | Fight hostile NPCs | Not implemented |
| 22 | Collect loot | Not implemented beyond resources/death recovery |
| 23 | Unlock better equipment | Research/bench progression not implemented |
| 24 | Survive environmental hazards | Fall/drowning/deprivation implemented; temperature/bleeding/radiation pending |
| 25 | Die and respawn | Production-scene regression passes |
| 26 | Recover belongings | Production-scene conservation regression passes |
| 27 | Return to existing base | Building persistence under validation |
| 28 | Save and quit | Browser manual save verified; Windows runtime pending |
| 29 | Restart game | Browser page reload verified; native executable restart pending |
| 30 | Continue same persistent world | M1 inventory/location verified; M2 structures/stations under validation |

None of this table establishes human playtesting, Windows runtime validation, Rust parity, suitable-hardware performance or 1.0 readiness. Update only from executed evidence.
