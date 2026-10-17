# SoloSurvival autonomous development instructions

Continue the existing single-player Godot 4/GDScript game; never recreate/reset it. Source: unknown0v/SoloSurvival, branch codex/godot-first-playable, draft PR #1. Read DEVELOPMENT_STATUS.md, ROADMAP.md, RUST_PARITY.md and RELEASE_CHECKLIST.md before work.

## Authority and environment
- Exactly one human, one persistent island, no multiplayer, runtime accounts or servers.
- Owner laptop has 20 GB free. Do not install or execute development tooling locally. Use GitHub MCP for remote source changes and public standard GitHub Actions runners for engine/build/browser execution.
- Additional infrastructure budget $0. No paid runner, paid API, Codespace or infrastructure. Check public visibility before workflows. No unrelated repository changes.
- Preserve immutable releases and the latest working Pages preview. Never reset history or force push. Use expected-SHA ref updates. No merge or human readiness attestation.
- Ordinary implementation, commits, tests, previews and draft-PR updates are authorized. Ask only for unavoidable account/payment/license authorization. Never claim unattended background execution after a session ends.

## Architecture and persistence
- Godot Compatibility Web, standalone offline Windows, same world seed 197403.
- Core models own inventory, crafting, construction and save validation; world adapters own meshes/colliders; UI calls production actions.
- Keep resource/item recipes data-driven. Transfers and costs must conserve items atomically; reserve output capacity before consumption.
- Existing save path user://island-v1.json is stable. Read schemas 1, 2 and 3; write schema 3. Preserve backups, integrity envelopes, rejected files and unsupported future versions. Add migration tests for every extension; never silently reset.
- Construction support must originate at foundations; disconnected cycles cannot support themselves. Nonempty affected storage blocks destruction until a persistent loot alternative exists.
- Preserve source inputs. JSON numbers are floats in Godot: validate integer bounds, compare numeric values explicitly, and normalize once at an owning boundary.

## Workflow and tests
1. Inspect remote branch head, commits, PR and current docs. Preserve in-progress work.
2. Implement dependency-ordered playable increments. Fix regressions before expanding.
3. Run cloud import/compile, domain and real-scene tests, Web/Windows exports and actual browser interactions. No local engine execution.
4. Differentiate headless, browser, Windows runtime and human validation. Never infer runtime success from export alone.
5. Publish only validated previews; preserve prior release assets. Update draft PR and project memory with exact tested source/run and limitations.
6. Continue through ROADMAP.md while execution allows; do not ask which ordinary phase is next.
7. Before stopping, push completed work, document incomplete work/blockers and exact continuation steps. Never label a prototype 1.0.

## Quality and scope
Original code/assets or documented compatible licenses only. No proprietary Rust assets/source, DRM bypass or parity claims without evidence. Functional gameplay precedes decoration. Keep modules focused and avoid duplicated parsers/representations. Maintain all six project-memory files in sync. Native Windows runtime, human playtest and suitable-hardware performance remain explicit release gates until measured.

## Latest continuation checkpoint
M2 source `b30937aefd4b0702c036603df3eb4e8af5471325` passed run 39044434999 with 95 assertions and full exported/public browser construction, cooking, smelting and durable reload checks. Preserve `preview-b30937aefd4b` and M1 releases. The active follow-up batches tree rendering and adds fuller browser wall/roof coverage; inspect its CI and fix regressions before further Phase A work. Browser save confirmation must compare the exact saved file in IndexedDB; never treat a staged write as durable. Continue building extensions/upkeep/deployables, then the remaining roadmap. See current DEVELOPMENT_STATUS.md for exact latest validation.

Active Phase A follow-up adds cupboard upkeep/decay, sleeping-bag binding/safe respawn and workbench-gated metal tools. SaveStore owns version-aware settlement extraction; never interpret extension fields from an older schema as newer state. Schemas 1/2 remain readable; schema 3 adds bound bags and maintenance clock/grace. New/migrated worlds get 30 simulated minutes of upkeep grace; no offline decay. Read current CI/status before claiming this increment verified.
