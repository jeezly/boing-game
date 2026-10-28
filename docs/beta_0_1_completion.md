# BOING — Beta 0.1 completion report

Date: 2026-10-27. Project: `D:\heezl\Documents\misjuegos\boing_game`.

## Executive summary and scope

The interrupted run made no changes. On resuming, the working directory was confirmed and both `git status --short` and `git diff --stat` were empty. Implementation extends the existing survival architecture; it does not replace the map or directors.

Beta 0.1 contains Mango, Pepsín, Resortera de Mango, and Mega Abarrotera Mexicana. Godot 4.7, GDScript, GL Compatibility, Jolt Physics, FPS/TPS, the ten-minute timer, timed Hot Zones, score, kills, projectile combat and health supplies are preserved. No addons, software, external art packs, additional enemies, weapons, economy, final power-ups or portfolio documents were added.

The implemented flow is READY → enter the store → survive ten minutes → VICTORIA, or lose all three lives → DERROTA. Reaching a zone never ends the match. Results support REINTENTAR and SALIR. Gameplay implementation and automated validation are complete; the human acceptance checklist below remains available for the submission playtest. A Windows executable has not been exported because templates are unavailable.

## Rules and controls

| Action | Control |
| --- | --- |
| Move | W / A / S / D |
| Look / aim | Mouse |
| Sprint | Left Shift |
| Jump | Space |
| Switch FPS / TPS | V |
| Fire Resortera de Mango | Left mouse button; hold to repeat |
| Buy first aid nearby | E |
| Pause / resume | Esc |
| Restart from results | REINTENTAR button, or R |
| Restart while paused | REINICIAR button |
| Settings | Esc → AJUSTES |
| Exit | SALIR button |

Startup shows ENTRA A LA ABARROTERA. Crossing the existing entrance Area3D starts the match once. Combat is disabled in READY. The clock begins at 10:00. Mouse sensitivity and Master volume are adjustable while paused. Sensitivity survives scene restarts within the application session; volume remains in AudioServer. Settings are not written to an external preferences file.

## Lives, life loss and safe respawn

`MatchController` owns `lives`, initially 3, and emits `lives_changed`. Mango's existing `died` signal consumes exactly one life. At zero lives the match ends immediately in defeat. Earlier deaths set a temporary recovery flag inside PLAYING; they do not reload the scene or begin a new match.

For an intermediate death:

1. Disable movement, mouse look, camera toggling and combat; clear active projectiles and velocity.
2. Show life-loss feedback and allow approximately 0.85 seconds for the existing death presentation. Pause freezes this interval.
3. `respawn_manager.gd` sorts twelve authored markers by proximity to the active Hot Zone, checks floor contact/slope, an expanded player capsule, the existing walkable map, and nine meters of enemy clearance.
4. Choose the nearest safe marker, falling back to another authored location if occupied.
5. If every geometrically clear marker is occupied, retire enemies within nine meters of the preferred fallback without awarding score. The original entrance position is the last defensive fallback. Every authored marker and that entrance position were checked in the engine.
6. Restore 100 HP, zero velocity, upright Mango reaction state, neutral camera pitch, the correct FPS/TPS weapon visibility and captured mouse. Preserve camera mode, yaw, timer, score, credits, kills, director state and Hot Zone participation.
7. Reject all damage for 2.75 seconds. The HUD shows PROTECCIÓN ACTIVA until protection expires. Shooting and movement are available during protection.

The clock continues during the brief life recovery. If it reaches 00:00 while Mango is recovering an available life, victory waits until Mango is alive again. A final-life death that occurs before the terminal victory transition produces defeat. Once a terminal result is committed, later callbacks cannot change it.

Authored markers: entrance; checkout west/east; central south/north; coolers; produce south/north; bodega south/north; patio south/north. No large checkpoint framework was introduced.

## Score, credits, kills and transactions

MatchController owns `total_score`, `spendable_credits` and `kills`. `score_changed`, `credits_changed`, `kills_changed` and `lives_changed` update the HUD by signal. The HUD never owns money or performance totals.

A Pepsín defeat grants 100 total score and 100 credits. The existing Hot Zone kill bonus grants an additional 50 to both when Mango is inside the active zone. Completing a participated Hot Zone grants the existing 500 bonus to both. Location alone never grants victory. Total score only increases; spending affects credits only. Both accounts and kills survive life loss and reset on a new match.

The physical PUESTO DE PRIMEROS AUXILIOS is near the entrance/checkouts at world position `(3, 0, -4)`. It has a solid cabinet, counter, green cross and a backed sign stating its service and price. Within 3.3 meters and with an unobstructed view, the HUD shows `[E] COMPRAR CURACIÓN — 500 CRÉDITOS`.

`healing_offer.tres` provides cost 500 and healing 50 through `purchase_offer.gd`. `healing_station.gd` handles proximity, line of sight and E; MatchController revalidates the station, current state, HP, offer and balance, then performs the transaction synchronously. Successful payment heals up to max HP, deducts exactly 500 credits and emits feedback with actual healing. Full health and insufficient credits change nothing and show SALUD COMPLETA or NO TIENES SUFICIENTES CRÉDITOS. Transactions are unavailable in READY, pause, life recovery and results. The data/service split can support later station offers without making the HUD authoritative; no full shop system exists.

## Health pickups

The eight existing authored supplies remain temporary Beta items. Each restores 30 HP, caps at 100, does not consume at full health or when dead, and disappears only after a valid collection. Existing overlap sampling handles a player who was already standing on a supply when damage occurs. Bob, rotation and pulse use pausable delta time. Every authored supply position passed floor/capsule access checks. Supplies do not regenerate on life loss; a fresh match restores them.

## Victory, defeat, pause and restart

Victory requires the timer to reach zero with Mango alive. Defeat requires lives to reach zero. Both terminal paths stop SurvivalDirector and ObjectiveDirector, disable player combat/movement, deactivate living enemies, clear projectiles, freeze the tree, release the mouse and show one results overlay. Results include total score, kills, remaining lives, remaining credits and survived time; victory reports exactly 10:00.

Esc opens PAUSA with REANUDAR, REINICIAR, AJUSTES and SALIR. Gameplay children remain pausable while MatchController and its menu process during pause. Tests verified frozen timer, player physics, AI, projectiles, pickup animation, Mango animation and life-recovery delay. Resume restores the same match and captured mouse.

Restart is guarded against repeated requests and reloads the existing main scene deferred. A new match starts READY with three lives, 100 HP, ten minutes, zero score/credits/kills, fresh directors and supplies, and no old enemies. Desktop SALIR uses SceneTree.quit; the existing web fallback returns to a fresh READY match. Exit still requires a final human click-through acceptance check.

## HUD and version presentation

The existing dark translucent palette was retained and organized using anchored panels and VBoxContainers. Top left contains camera mode, HP, a green health bar, VIDAS and temporary protection. Top center contains timer and objective. Top right contains PUNTOS, CRÉDITOS and BAJAS. Bottom left contains Resortera de Mango and Ammo: infinite. Interaction and transaction feedback appear contextually near the bottom center.

Pause/results hide gameplay HUD panels and display `BOING — Beta 0.1`. Project metadata is `0.1.0-beta`. Review images confirmed readable results and the settings menu at 1280×720 and settings at 960×640. The minimum window size is 960×640; the development viewport is 1280×720 with the existing canvas scaling mode.

## Mega Abarrotera presentation

Existing fixture positions, cover lanes, ramps, zone rectangles, spawns and planar navigation are retained.

- **Acceso:** a striped neighborhood-store awning frames the existing entrance. Existing carts/crates remain; reusable modeled garrafones now have a neck, cap, ribs and fictional AGUA DEL BARRIO label.
- **Cajas:** existing lanes/registers gain small candy-wrapper batches, register keys, receipt strips and supported offer cards for DULCES LA ESQUINA. Existing lane numbers and HOY SÍ HAY CAMBIO signage remain.
- **Pasillos:** eight aisle categories use distinct palettes and lightweight packet, cereal-box, can or bottle silhouettes. Shared label strips and bottle caps use MultiMesh. Physically backed shelf-end offers introduce CRUJIMANGO, BRILLA BONITO, LA COSECHITA, CASA CONTENTA, MAÑANITAS, LA BURBUJITA, DULCES LA ESQUINA and EL COSTALITO.
- **Refrigeradores:** tinted transparent door panels, frames/rails, handles and beverage silhouettes give a stronger fridge impression. The existing cool light remains.
- **Frutas/granel:** bins gain slats/corner hardware and supported market cards. Sack stamps/stitches complement the existing costales. A wall-mounted fruit mural and restrained tile-color band establish DE NUESTRA TIERRA identity; warm fill separates the market zone.
- **Bodega:** retail stock becomes muted carton stock with cargo labels. Existing pallets, boxes, hand trucks, catwalk and ramps remain. Upper wall panels close visible roof gaps above playable height.
- **Patio:** existing loading layout, truck, pallets and returnable-bottle crates remain. Truck wheels and distinct service-yard light improve readability. The truck cab now has a matching simple collider and navigation footprint.
- **Shared atmosphere:** the existing rectangular papel picado uses a reusable cut-paper/scallop shader; three sphere placeholders are hidden in favor of reusable seven-point star piñatas with colored paper bands/tails and roof-height suspension. A shared floor shader adds subtle worn tile joints indoors and concrete outdoors. Ambient/sun intensity was reduced to control pale-surface blowout. The objective beacon respects depth and is narrower/smaller, avoiding draw-through on Mango.

Small decoration has no physics bodies. Large fixtures retain simple box collision. Product meshes/materials are cached and repeated goods use MultiMesh; immutable fixture/piñata/mural details use the existing visual batching helper. No downloaded textures or expensive per-product models were added.

## Mango and Pepsín review

Mango's approved body, helmet, goggles, face, backpack, boots and visual style are preserved. Concrete fixes: reset collapsed death/hit state after respawn, restore the FPS weapon, gate camera input during life recovery/results, freeze presentation during pause and move the FPS weapon slightly forward/down for a cleaner view. Loaded mango ammunition, projectile launch, hit response and FPS/TPS sockets remain the existing architecture.

Pepsín's blue/red goblin identity, ears, goggles, jester cap and soda weapon are unchanged. Inspection and rendered horde review found no concrete reason to redesign or rewrite him. His existing anticipation, weapon sockets, fire response, hit cancellation/stun, death collapse and static visual batching are retained. Real projectile damage in both directions and visible horde behavior were tested. No Pepsín production source file required modification.

## Collision/navigation findings

Collision convention remains world = layer 1, Mango = layer 2, Pepsín = layer 4. Mango's mask is 5, Pepsín's is 7, mango projectiles use mask 5 and soda projectiles mask 3. Pickups monitor layer 2 with no physical layer. The new station uses world layer 1/mask 7 and is indexed as a navigation obstacle before the environment builds its grid.

The concrete missing-collision finding was the existing truck cab, previously only a large visual mesh. A matching box collider now prevents walking/shooting through it and adds its footprint to the existing scan. All 38 enemy spawn markers, 12 respawn markers and eight pickup positions passed floor/capsule checks. Connected ground routes to all respawn markers were checked using the existing AStar grid. Real movement into a shelf stopped correctly and the bodega ramp was climbed using actual input/Jolt physics. Spawn selection was checked for minimum distance and rejected visibility. A crowded preferred respawn selected another location; a saturated fallback retired nearby enemies safely.

Navigation remains the existing two-dimensional ground grid with physical CharacterBody movement. It does not become a full multi-level navigation mesh: Mango can use the bodega catwalk, while Pepsín routes primarily at ground level and attacks through line of sight. Decorative labels/paper/stock remain non-colliding. A human should still walk every ramp edge, corner and route in the checklist.

## Validation evidence

Godot was not on PATH, but the existing project metadata identified `D:\heezl\Escritorio\godot\Godot_v4.7.2-stable_win64_console.exe`; that installed engine was used without installing anything. Logs and screenshots were redirected into ignored `.godot/` paths in this project. Test helper processes also redirected APPDATA/LOCALAPPDATA into `.godot/beta_runtime/`.

- `beta_0_1_smoke.gd`: life flow, economy, pickup rules, physical marker clearance, pause, camera modes, results and fresh restart.
- `beta_gameplay_audit.gd`: loads all script/scene/resource files; checks rendering/physics settings and E mapping; exercises real movement/sprint/jump, solid shelf/cab collision, ramp climbing, mango and soda projectiles, AI/presentation pause, both settings, ground connectivity, hidden spawn choice, saturated respawn and terminal races.
- `beta_visual_review.gd`: saved 17 OpenGL review images covering READY, FPS, TPS, station, both menu sizes, each map zone, façade, piñata/garrafón closeups and both results. These images are local QA artifacts, not exported assets.
- `beta_horde_review.gd`: a 20-second rendered final-minute configuration at 1280×720, 22 active enemies, peak nine projectiles, on NVIDIA GTX 1650 Max-Q / OpenGL Compatibility. Measured 1,200 frames, mean 16.68 ms (60.0 FPS), p95 18.36 ms. The helper uses temporary test invulnerability; normal gameplay does not.
- Static audit found no missing referenced resources, undeclared ExtResource/SubResource IDs or duplicate script UIDs. Production scripts contain no debug-print spam; test prints remain under scripts/test. The unused debug hitscan prototype was archived with its UID.

Final validation record: **103 smoke/integration checks and 148 gameplay/resource checks, zero failures**. The final smoke run also used the real E-key interaction path, parsed the Windows export preset and invoked the connected desktop SALIR button to exit successfully. Static scanning resolved **137 resource references and 38 script UIDs with zero problems**; `git diff --check` passed. The authored source manifest is **19 created files, 23 modified files and two moved files**; the moved files also appear as new paths in an unstaged Git status. The ignored QA folder contains 17 visual review images plus the separate horde image. Short deterministic tests and the rendered horde sample do not replace a full ten-minute human acceptance session or an exported build test.

To rerun locally from PowerShell at the project root, using the installed engine:

```powershell
$env:APPDATA = "$PWD/.godot/beta_runtime/appdata"
$env:LOCALAPPDATA = "$PWD/.godot/beta_runtime/local"
$godot_exe = 'D:/heezl/Escritorio/godot/Godot_v4.7.2-stable_win64_console.exe'
& $godot_exe --headless --path . --log-file .godot/beta_smoke.log --script res://scripts/test/beta_0_1_smoke.gd
& $godot_exe --headless --path . --log-file .godot/beta_gameplay_audit.log --script res://scripts/test/beta_gameplay_audit.gd
```

Visual helpers require a graphical display, so omit `--headless` and use their corresponding script paths. All test helpers are opt-in and absent from production scene references and the export preset.

## Windows export/build status

`export_presets.cfg` contains runnable **Windows Desktop / BOING Beta 0.1**, x86_64, project version 0.1.0.0, external PCK, unsigned, with output `builds/windows/boing_beta_0_1.exe`. Build outputs are ignored by Git. Reference documentation and test content are excluded. GL Compatibility and Jolt remain project settings. The existing export-template directory contains no Windows template executables; no EXE/PCK was fabricated and no templates were downloaded.

Manual editor steps when matching templates are already available:

1. Open this project's `project.godot` in the installed Godot 4.7.2 editor.
2. Use **Editor → Manage Export Templates** and verify a matching 4.7.2 template package is present. If unavailable, obtain/install the matching templates separately under the user's own approval; this task did not install them. Existing templates from another version are not sufficient.
3. Open **Project → Export** and select the supplied **BOING Beta 0.1** Windows Desktop preset. Confirm x86_64, main scene `res://scenes/game/main.tscn`, name/version and the exclusion filters. Keep codesigning disabled unless a real certificate is supplied later.
4. Create `builds/windows/` inside this project if necessary. Click **Export Project**, select `builds/windows/boing_beta_0_1.exe`, and disable **Export With Debug** for the submission release.
5. Keep `boing_beta_0_1.exe` and its generated `.pck` together. Launch the exported executable from a clean folder inside the project build directory and complete the checklist below. Package both files for delivery; do not submit only the EXE when PCK embedding is disabled.
6. Confirm restart, exit, mouse capture, GL graphics and ten-minute victory in the exported build. No successful standalone-export validation is claimed until this step is performed.

## Exact authored file manifest

Paths below are relative to the project root. Generated `.godot/` cache, logs, metrics and screenshots are excluded from this source manifest.

### Created

```text
docs/beta_0_1_completion.md
export_presets.cfg
resources/environment/papel_picado.gdshader
resources/environment/store_floor.gdshader
resources/game/healing_offer.tres
scenes/environment/mega_abarrotera/modules/market_mural.tscn
scenes/environment/mega_abarrotera/modules/star_pinata.tscn
scenes/environment/mega_abarrotera/modules/water_jug.tscn
scenes/game/healing_station.tscn
scripts/environment/mega_abarrotera/fixture_details.gd
scripts/environment/mega_abarrotera/market_mural.gd
scripts/environment/mega_abarrotera/star_pinata.gd
scripts/game/healing_station.gd
scripts/game/purchase_offer.gd
scripts/game/survival/respawn_manager.gd
scripts/test/beta_0_1_smoke.gd
scripts/test/beta_gameplay_audit.gd
scripts/test/beta_horde_review.gd
scripts/test/beta_visual_review.gd
```

### Modified

```text
.gitignore
project.godot
scenes/environment/mega_abarrotera/mega_abarrotera.tscn
scenes/environment/mega_abarrotera/modules/checkout_module.tscn
scenes/environment/mega_abarrotera/modules/costales.tscn
scenes/environment/mega_abarrotera/modules/fridge_bank.tscn
scenes/environment/mega_abarrotera/modules/produce_display.tscn
scenes/environment/mega_abarrotera/modules/shelf_module.tscn
scenes/environment/mega_abarrotera/objective_beacon.tscn
scenes/game/main.tscn
scenes/game/survival/match_controller.tscn
scenes/ui/hud.tscn
scenes/ui/survival_hud.tscn
scripts/characters/mango/camera_controller.gd
scripts/characters/mango/mango_visual.gd
scripts/characters/mango/player_controller.gd
scripts/components/character_reactions.gd
scripts/environment/la_abarrotera/store_builder.gd
scripts/environment/mega_abarrotera/shelf_stock.gd
scripts/game/survival/match_controller.gd
scripts/ui/hud.gd
scripts/ui/survival_hud.gd
scripts/weapons/projectile_weapon.gd
```

### Moved/renamed

```text
scripts/weapons/hitscan_weapon.gd
  → scripts/test/legacy/hitscan_weapon.gd
scripts/weapons/hitscan_weapon.gd.uid
  → scripts/test/legacy/hitscan_weapon.gd.uid
```

The archived hitscan source only gains an explanatory comment; its UID is preserved. No current scene references it. Existing test dummies, graybox and legacy encounter manager remain under test folders. Dormant alternate-store resources remain available and are not connected to main gameplay; the shared store_builder helper still serves current fixtures.

## Remaining placeholders and known limitations

- Art remains native-mesh Beta presentation, not final production art. Packaging is lightweight fictional color/silhouette art; tiny labels are intentionally readable only nearby. Simple decorative objects do not have individual collision.
- The health kits and station are Beta service props, not the final power-up or inventory system.
- Pepsín navigation remains planar; no multi-level AI navigation was added. Broad combat lanes and scale remain those of the proven map.
- No new music/SFX or external assets were added. The volume slider controls the real Master bus, including any subsequently attached project audio; settings are session-only.
- Visual review covered the development and minimum window sizes, not every aspect ratio/GPU. The 20-second GPU sample is evidence on one device/configuration, not a guarantee for all hardware or a full ten-minute soak.
- A human must complete both an unassisted ten-minute session and an exported-build acceptance pass. Windows templates and standalone export are unavailable in the current environment.
- Old sphere-based piñata placeholders are hidden in the authored scene rather than destructively deleted. The current visible stars are the reusable replacement modules.

## Complete manual Beta acceptance checklist

Leave boxes unchecked until a human verifies them in the actual play session. Automated evidence above supplements these checks; it does not silently mark manual observations complete. Run once in-editor and again in the exported build when available.

- [ ] **A. Project launches:** open project with Godot 4.7.2; no missing-resource/parser errors.
- [ ] **B. Main scene loads:** F5 opens Mega Abarrotera with ENTRA A LA ABARROTERA and ten minutes ready.
- [ ] **C. Movement:** WASD responds consistently and stops when released.
- [ ] **D. Jump:** Space leaves the floor and lands without embedding in geometry.
- [ ] **E. Sprint:** Shift increases movement speed and returns to walk on release.
- [ ] **F. FPS/TPS:** V switches both cameras, with matching weapon state and sensible camera collision.
- [ ] **G. Resortera:** left click/hold launches visible mango projectiles with infinite ammo and proper cooldown.
- [ ] **H. Mango hits Pepsín:** projectiles collide, flash/stun him and defeat him after sufficient hits.
- [ ] **I. Pepsín attacks:** approach, strafe, anticipation, soda shot and reposition behavior are visible.
- [ ] **J. HP decreases:** soda impacts lower HP once per projectile; walls block shots.
- [ ] **K. Pickup heals:** damaged Mango collects a kit for up to 30 HP and it disappears.
- [ ] **L. Pickup cap:** heal near 100; HP caps at 100. Full-health overlap leaves the kit available.
- [ ] **M. Score:** a kill increases PUNTOS, including the active-zone bonus where applicable.
- [ ] **N. Credits:** the same reward increases CRÉDITOS; totals are distinct and correctly displayed.
- [ ] **O. Purchase succeeds:** below max HP with ≥500 credits, approach first aid and press E; gain up to 50 HP, lose 500 credits, retain total score.
- [ ] **P. Insufficient credits:** below 500, press E; see the rejection and retain HP/balance.
- [ ] **Q. Full health purchase:** at 100 HP, press E; see SALUD COMPLETA with no charge.
- [ ] **R. Initial lives:** a fresh match shows VIDAS ×3 and 100 HP.
- [ ] **S. First death:** reach zero HP; lives become two, controls briefly disable and Mango recovers.
- [ ] **T. Preserved progress:** after respawn compare timer, score, credits, kills and Hot Zone with values before death.
- [ ] **U. Invulnerability:** immediately after respawn, incoming shots do not damage for approximately 2.75 seconds; protection indicator clears afterward.
- [ ] **V. Final defeat:** consume all three lives; only the last death produces DERROTA with zero lives.
- [ ] **W. Entrance event:** crossing the entrance starts exactly one match/director; recrossing does not reset it.
- [ ] **X. Ten-minute clock:** play a full unpaused session and confirm countdown length; life losses do not reset it.
- [ ] **Y. Hot Zones:** observe cajas 10:00–8:30, pasillos 8:30–7:00, refrigeradores 7:00–5:30, frutas 5:30–4:00, bodega 4:00–2:30, patio 2:30–1:00 and final patio minute 1:00–0:00. Travel never auto-wins.
- [ ] **Z. Spawn scaling:** pressure increases at 2/4/6/8/9 elapsed minutes; live caps remain 8/10/14/18/20/22.
- [ ] **AA. Pause:** Esc freezes timer, AI, spawning, projectiles, movement, firing, pickup animation and life recovery while buttons/sliders remain usable.
- [ ] **AB. Resume:** REANUDAR/Esc restores the same match and captured mouse; no unintended click fires during menu use.
- [ ] **AC. Restart:** restart from pause, victory and defeat; each returns READY with fresh counters, three lives, full health, supplies and no old enemies/directors.
- [ ] **AD. Victory:** survive to 00:00; VICTORIA appears, combat/spawns stop and survived time reads 10:00.
- [ ] **AE. Exclusive results:** damage near 00:00 never creates both results. Final-life death before victory defeats; recovery with an available life completes before pending victory.
- [ ] **AF. Results:** compare total score, kills, survived time, remaining lives and credits against the match; one overlay appears.
- [ ] **AG. Environment collisions:** walk/fire into walls, shelves, counters, the first-aid cabinet, loading truck/cab and large cover; tiny decorative goods do not snag Mango.
- [ ] **AH. Bodega ramps:** climb and descend both ramps, traverse the catwalk and test rail/corner transitions in FPS and TPS.
- [ ] **AI. Hidden spawns:** turn and travel through zones; enemies do not visibly appear directly in front of Mango or within the configured minimum distance.
- [ ] **AJ. Respawn safety:** lose lives in different Hot Zones, including a crowded final minute; no placement inside fixtures/enemies and no unavoidable immediate damage.
- [ ] **AK. FPS cleanliness:** look up/down, sprint, fire, take damage and switch after respawn; body/backpack/helmet do not intrude into first person.
- [ ] **AL. TPS Mango:** inspect silhouette, boots, preserved backpack, held weapon, movement and life-loss recovery without detached/clipped parts.
- [ ] **AM. Pepsín hordes:** verify cap/ears/goggles, soda weapon, windup, hit response and death remain legible in groups.
- [ ] **AN. Signage:** physical offers/aisle signs/paper/piñatas do not block essential sight lines; objective marker does not draw through actors.
- [ ] **AO. Final-minute performance:** complete the real final minute on the submission machine; note FPS/stutters alongside this report's limited 22-enemy GPU sample.
- [ ] **AP. Exit:** SALIR closes the standalone application cleanly; repeat from pause and both results screens.

Additional presentation check: adjust both sliders, restart, resize to 960×640 and back, confirm readable menus/HUD, then record final beta-test observations separately. This task stops at Beta 0.1 and does not begin academic portfolio documents.
