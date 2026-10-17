# Complete-game acceptance record

Latest evidence: [run 39048713145](https://github.com/unknown0v/SoloSurvival/actions/runs/39048713145), source `4f07a3bd5d20a8b5bfc87d9553010209b958694a`. Browser cases use valid imported supplies through the actual file picker; this is integration coverage, not an end-to-end human progression walkthrough. Windows runtime remains unverified.

| # | Player action | Executed evidence / remaining acceptance |
|---|---|---|
| 1 | Start a new world | Fresh browser startup passes; explicit new-game UI pending |
| 2 | Spawn on island | Exported/hosted browser passes |
| 3 | Walk/sprint/crouch/jump/swim | Walking browser and real stair physics pass; complete graphical movement walkthrough pending |
| 4 | Gather wood/stone | Browser fully depletes tree; resource/tool production tests pass; full human gathering loop pending |
| 5 | Craft tools | Browser plan/hammer and bench metal tool pass; primitive recipes/model tests pass |
| 6 | Manage inventory | Browser toggle/bulk transfers/persistence; headless stacking/splitting/transfers; browser drag/split pending |
| 7 | Hunt animals | Not implemented |
| 8 | Collect food/water | Plants/river/consumables implemented; fuller graphical walkthrough pending |
| 9 | Build foundations | Production physics and browser placement pass |
| 10 | Place walls/roofs | Exported/hosted building passes; windows/half walls/stair landing additionally exported-browser tested |
| 11 | Add doors | Browser placement/open/close and physical obstruction tests pass |
| 12 | Upgrade structures | Four-tier model tests; browser door upgrade passes |
| 13 | Repair structures | Model tests and browser damage/repair pass |
| 14 | Place storage | Browser placement, transfer and durable reload pass |
| 15 | Place campfire | Exported-browser resource-cost placement passes |
| 16 | Cook food | Exported-browser berry cooking and persistence pass; hunting/meat pending |
| 17 | Place furnace | Exported-browser cost/placement passes |
| 18 | Smelt ore | Exported-browser smelting/stop/save/reload passes |
| 19 | Craft weapons | Not implemented |
| 20 | Explore monuments | Not implemented |
| 21 | Fight hostile NPCs | Not implemented |
| 22 | Collect loot | Death recovery/resources exist; world loot pending |
| 23 | Unlock equipment | Basic nearby-workbench metal tool browser tested; research/advanced tech pending |
| 24 | Survive hazards | Fall/drowning/deprivation implemented; status/biome hazards pending |
| 25 | Die/respawn | Real-scene death, clear bound bag/bed spawn and fallback tests pass; human walkthrough pending |
| 26 | Recover belongings | Production-scene conservation tests pass |
| 27 | Return to base | Building/storage/station persistence and walked upper-floor reload pass |
| 28 | Save/quit | Browser durable acknowledgement tested; native runtime pending |
| 29 | Restart game | Browser reload passes; native restart pending |
| 30 | Continue world | Position/items/building/station/binding reload coverage passes; full long-play/native/human walkthrough pending |

Also tested: upkeep payment/decay/separate bases headlessly, cupboard inventory and bag binding graphically, old-schema imports, unsupported future saves, backups and failed/cancelled confirmation semantics. Public smoke checks compiled source and core construction/storage; it does not repeat every exported-browser case.

No human, native Windows, Firefox/Safari, hardware benchmark, full-game completion or Rust-parity claim is established here.
