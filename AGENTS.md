# SoloSurvival permanent development instructions

Build the complete independent, offline single-player survival game described in ROADMAP.md; continue ordinary development without asking which milestone is next. Never recreate/reset this project. Read DEVELOPMENT_STATUS.md, ROADMAP.md, RUST_PARITY.md, ASSET_LICENSES.md and RELEASE_CHECKLIST.md first.

## Repository and current checkpoint
- Source: unknown0v/SoloSurvival. Branch: codex/godot-first-playable. Draft PR #1.
- Latest verified gameplay source: `4f07a3bd5d20a8b5bfc87d9553010209b958694a`; [run 39048713145](https://github.com/unknown0v/SoloSurvival/actions/runs/39048713145).
- 145 Godot assertions, five JavaScript confirmation cases, Web/Windows exports, full exported-browser integration and hosted core/construction/save checks passed.
- Browser: https://unknown0v.github.io/SoloSurvival/
- Preserve release `preview-4f07a3bd5d20`, all earlier validated releases and the generated gh-pages history. Documentation-only commits may follow the tested gameplay SHA; query the actual branch head before editing.

## Authority, budget and environment
- Exactly one human and one persistent island; no multiplayer, online accounts, matchmaking, dedicated server, microtransactions or extra maps.
- Owner laptop has 20 GB free. Never install or execute development tooling locally. Do not modify unrelated repositories, including the local REA workspace.
- Use GitHub MCP for remote edits and public standard GitHub Actions runners for builds/tests. Additional infrastructure budget $0: no paid services/APIs/runners, Codespaces or quota overruns.
- Ordinary implementation, commits, cloud checks, previews and draft-PR updates are authorized. Ask only for unavoidable account/payment/license authorization.
- Use expected-SHA ref updates, no resets/force pushes. Do not merge or assert human review/readiness on the owner's behalf.
- No unattended scheduling/background execution is configured after a session ends; never claim otherwise.

## Architecture and ownership
- Godot 4.7.2/GDScript, Compatibility Web and standalone Windows. Keep seed 197403 and existing terrain vertex heights.
- Inventory/crafting/settlement/save models own semantics; world adapters own meshes/colliders; UI invokes production actions.
- Player.update_target parses live physics metadata once into stable domain IDs. Consumers must resolve IDs through the owning model; never retain freed collider objects across rebuilds.
- Player movement_intent is commanded horizontal motion; CharacterBody.velocity is collision output. Use floor snapping for grounding. Preserve the real stair ascent regression.
- Settlement owns piece kinds, support, costs, upgrades, repairs, destruction, upkeep and spawn binding. landing_on_stairs owns the landing relationship for both support and physical contact.
- Coalesce station/upkeep mutations into one change notification per tick. Preserve per-resource forest instance ownership when batching/LOD changes.
- Buildings currently use square 3 m cells. Triangle work must extend the pose/geometry contract without shifting existing square poses or saved identities.
- Keep item transfers/costs atomic and capacity safe. Nonempty affected containers currently block destruction/decay collapse; add persistent debris/loot ownership before relaxing this protection.
- No proprietary Rust source/assets, DRM bypass or unsupported parity claims. Use original or compatible licensed assets; update ASSET_LICENSES.md.

## Persistence
- Stable path: user://island-v1.json. Read schemas 1–4; write SaveStore.CURRENT_VERSION (4).
- SaveStore.supported_world owns format recognition; settlement_state owns version-aware extraction. Never interpret newer extension fields in an older schema.
- Keep digest envelopes, backups, malformed-file preservation and unsupported-future-version write blocking. Never silently reset progress.
- Schema 3 added upkeep grace/clock and bound bags; schema 4 extends the piece catalog. Old saves get a one-time 30 simulated-minute upkeep grace. No offline simulation/decay.
- Browser saving succeeds only after exact-file IndexedDB confirmation; a staged filesystem write is not durable success. Retain cancellation/error handling and callback ownership.
- CI stamps scripts/build_info.gd with the compiled source SHA. Keep the tracked placeholder; never commit generated CI identities.
- New permanent references such as lock keys will need an identity policy stronger than recycling deleted bN IDs after reload; design that before inventory metadata/locks.

## Validation and continuation
1. Inspect remote head, PR, source and latest CI; preserve in-progress work.
2. Implement dependency-ordered playable increments; fix regressions before expanding.
3. Run import/compile, domain and real-scene tests, exports, package/license checks and actual browser input.
4. Full exported-browser suite exercises fixtures through the shipped import UI. Hosted repeat verifies compiled source, core gameplay, construction and durable storage reload. Do not conflate their coverage.
5. Headless, browser, Windows runtime and human playtesting are different evidence. Windows export alone is not a runtime test.
6. Publish only validated previews, retain prior releases, update current PR and all project memory with exact tested SHA/run and limitations.
7. Markdown-only changes intentionally skip expensive engine/export runs; preserve a link to the tested gameplay source.
8. Continue ROADMAP.md until available execution ends; before stopping, commit/push, record incomplete work/blockers and make resumption explicit.

Next: triangle foundations/floors and remaining Phase A gaps; inventory instance/drop ownership is a prerequisite for robust locks and destructive loot. Then continue survival/equipment, combat, wildlife/NPCs, monuments, research, art/audio/UI, performance and native runtime verification. This checkpoint is not 1.0.
