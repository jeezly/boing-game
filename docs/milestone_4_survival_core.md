# Milestone 4 — existing survival core and validation completion

This document records the survival foundation already present when the Milestone 4A pass resumed. The core and Mega Abarrotera layout were preserved. Presentation changes and the exact current-pass file list are documented in `milestone_4a_presentation_playability.md`.

## Architecture

Production startup is `res://scenes/game/main.tscn`. It instances Mega Abarrotera, Mango/player, the match scene and HUD, with lighting and world environment kept at the top level. Godot 4.7, GDScript, GL Compatibility and Jolt settings are preserved; no addons or downloaded dependencies were added.

| Responsibility | Existing implementation |
| --- | --- |
| Match state, timer, score, results, pause/restart | `scripts/game/survival/match_controller.gd` |
| Time-driven objectives and participation bonuses | `scripts/game/survival/objective_director.gd` |
| Bounded pressure and registered enemy definitions | `scripts/game/survival/survival_director.gd` |
| Authored spawn eligibility/selection | `scripts/game/survival/spawn_manager.gd` |
| Enemy scene/weight/kill-score resource contract | `scripts/game/survival/enemy_definition.gd` |
| Current registered enemy | `resources/enemies/pepsin_definition.tres` |
| Zone/spawn indexing and objective beacon selection | `scripts/environment/mega_abarrotera/mega_abarrotera.gd` |
| Ground navigation | `scripts/environment/mega_abarrotera/planar_navigation.gd` |
| Signal-driven survival text | `scripts/ui/survival_hud.gd` |

The match scene separates objective director, spawn manager, survival director and active enemy container. Match/UI processing remains available during pause, while gameplay children explicitly use pausable processing. HUD listens to time, objective, state, score and kill signals; existing HP/camera/weapon bindings remain separate.

## Match rules

- READY: Mango starts outside; objective is ENTRA A LA ABARROTERA. Timer remains at 10:00 and combat spawning has not started.
- Crossing the entrance starts PLAYING once. The match advances by time, not kills or location.
- At 0 HP: DEFEAT. At 00:00 while alive: VICTORY. HP is checked before the terminal timer boundary, and terminal guards prevent duplicate results.
- Ending stops the director/objectives, disables player combat/movement, queues active projectiles for removal, pauses remaining combat, releases the mouse and shows score/kills/survived time.
- Pause remembers READY or PLAYING, stops gameplay/timer, and resumes the same match. Results cannot resume combat.
- Restart is guarded against duplicate requests and defers `reload_current_scene()`. State, enemy container, timer and authored health supplies belong to the scene and are recreated. Desktop exit quits; web exit safely restarts to READY.
- Reaching the rear of the map never finishes the production match. Legacy encounter logic is isolated under test content and is not instanced by main.

## Timeline and score

| Remaining time | Hot Zone |
| --- | --- |
| 10:00–08:30 | Cajas |
| 08:30–07:00 | Pasillos centrales |
| 07:00–05:30 | Refrigeradores |
| 05:30–04:00 | Frutas y granel |
| 04:00–02:30 | Bodega |
| 02:30–01:00 | Patio de carga |
| 01:00–00:00 | Patio de carga — ¡DESMADRE FINAL! |

Pepsín gives +100 score per confirmed death and one kill. If Mango is inside the current Hot Zone at the kill event, add +50. A phase gives +500 at its end if Mango entered that zone during the phase; participation is tracked independently of kills. Final-phase participation is resolved before VICTORY. Score never decreases; this is not a currency or purchasing system.

## Pressure and spawning

| Elapsed | Active cap | Spawn interval | Batch limit |
| --- | ---: | ---: | ---: |
| 0:00–2:00 | 8 | 3.40 s | 1 |
| 2:00–4:00 | 10 | 2.80 s | 1 |
| 4:00–6:00 | 14 | 2.30 s | 2 |
| 6:00–8:00 | 18 | 1.70 s | 2 |
| 8:00–9:00 | 20 | 1.25 s | 2 |
| 9:00–10:00 | 22 | 0.95 s | 3 |

The director counts living instances, deduplicates deaths and recycles enemies beyond 78 m without score. It uses scene definition resources; only Pepsín is registered. Individual Pepsín behavior retains movement/repositioning/shooting and lightweight local separation. No new enemy type or bullet-sponge scaling is introduced.

Thirty-eight saved markers are grouped by zone. Selection checks walkable ground, a route, ground-ray clearance, distance (14–65 m), separation from living enemies and marker reuse cooldown. Camera visibility checks body/head/side samples with world occlusion; directly visible points are rejected without a visible fallback. Selection weights the current zone 3.0, neighbors 1.6 and other zones 0.6, adjusted for distance. If no valid point exists, spawning retries later rather than forcing a pop-in.

## Environment and navigation

The existing 150 × 110 m authored environment exposes architecture, fachada/access, cajas, central aisles, refrigerators, produce/grains, bodega, patio, navigation, spawns, objectives and lighting. Six checkout lanes, eight split aisles and connected cross-routes are already saved in scenes. Bodega includes a supported walkway and industrial ramps; enemies navigate ground routes, not the elevated walkway.

Shelf, fridge, checkout, produce, crate, pallet, sack, cart, hand-truck, fan and sign modules are reusable saved scenes. Only repeated non-colliding shelf goods use small editor-visible MultiMesh generation. Large gameplay fixtures/collision remain inspectable in the editor.

Planar AStarGrid2D navigation uses 1.5 m cells and 0.62 m clearance derived from saved static fixture footprints. The static audit reconstructs 112 navigation obstacles and confirms all 5,626 free cells are connected to the player, including every authored spawn and objective. Static collision masks keep player/world/enemy projectiles distinct. This is a conceptual/navigation-geometry audit, not an executed Godot pathfinding test.

## Completed review and remaining limits

Godot was unavailable on PATH; no installation was attempted. Resource/preload paths, scene identifiers/parents, literal/default NodePaths, main integration, masks, HP/death wiring, director death signal arity, objective boundaries, score guards, pause modes and restart/terminal guards passed static review. Offline timer/scoring/state models were checked; they do not substitute for runtime execution.

During the resumed presentation pass, core source hashes stayed unchanged. No concrete core defect required a rewrite. Mango's movement, FPS/TPS, resortera gameplay, backpack and Pepsín art/logic were preserved.

Balance, collision under Jolt, real camera/spawn visibility, horde congestion, full-match results/restarts and final-minute frame time require manual testing. Native environment/character art, lighting and HUD are temporary stylized presentation. Ground-only navigation does not provide enemy traversal of the raised maintenance walkway.

Use the full manual checklist in `milestone_4a_presentation_playability.md`: startup/entrance, complete timer and every Hot Zone, beacons, hidden spawning, pathfinding/spacing, both damage directions, score/kills/bonuses, pause/resume, defeat/restart, victory/restart, FPS/TPS through every zone, health pickups, boots and final-minute performance.

## Existing Milestone 4 file history

The following manifest describes the core implementation that existed before the resumed 4A edits. It is separate from the current-pass manifest above.

### Created for the existing core

- `resources/enemies/pepsin_definition.tres`
- `scenes/environment/mega_abarrotera/mega_abarrotera.tscn`
- `scenes/environment/mega_abarrotera/objective_beacon.tscn`
- `scenes/environment/mega_abarrotera/modules/bottle_crate.tscn`
- `scenes/environment/mega_abarrotera/modules/checkout_module.tscn`
- `scenes/environment/mega_abarrotera/modules/costales.tscn`
- `scenes/environment/mega_abarrotera/modules/fridge_bank.tscn`
- `scenes/environment/mega_abarrotera/modules/hand_truck.tscn`
- `scenes/environment/mega_abarrotera/modules/huacal.tscn`
- `scenes/environment/mega_abarrotera/modules/pallet_stack.tscn`
- `scenes/environment/mega_abarrotera/modules/produce_display.tscn`
- `scenes/environment/mega_abarrotera/modules/shelf_module.tscn`
- `scenes/environment/mega_abarrotera/modules/shopping_cart.tscn`
- `scenes/environment/mega_abarrotera/modules/sign.tscn`
- `scenes/environment/mega_abarrotera/modules/store_fan.tscn`
- `scenes/game/survival/match_controller.tscn`
- `scenes/ui/survival_hud.tscn`
- `scripts/components/visual_batcher.gd`
- `scripts/environment/mega_abarrotera/combat_zone.gd`
- `scripts/environment/mega_abarrotera/mega_abarrotera.gd`
- `scripts/environment/mega_abarrotera/planar_navigation.gd`
- `scripts/environment/mega_abarrotera/shelf_stock.gd`
- `scripts/game/survival/enemy_definition.gd`
- `scripts/game/survival/match_controller.gd`
- `scripts/game/survival/objective_director.gd`
- `scripts/game/survival/spawn_manager.gd`
- `scripts/game/survival/survival_director.gd`
- `scripts/ui/survival_hud.gd`

### Modified for the existing core, before this pass

- `scenes/game/main.tscn`
- `scenes/ui/hud.tscn`
- `scripts/characters/mango/player_controller.gd`
- `scripts/enemies/pepsin/pepsin.gd`
- `scripts/enemies/pepsin/pepsin_visual.gd`
- `scripts/projectiles/projectile.gd`
- `scripts/weapons/projectile_weapon.gd`
- `scripts/weapons/soda_blaster_visual.gd`

### Earlier test-isolation moves

- `scenes/game/encounter_manager.tscn` → `scenes/test/legacy_encounter_manager.tscn`
- `scripts/game/encounter_manager.gd` → `scripts/test/legacy_encounter_manager.gd`
- `scripts/game/encounter_manager.gd.uid` → `scripts/test/legacy_encounter_manager.gd.uid`

Godot-generated import/UID files may appear when the editor imports the project. The two milestone documents were added during validation completion, rather than during the earlier implementation run.
