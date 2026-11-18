# Production V2 Combat / UI

Date: 2026-10-28. Engine used: installed Godot 4.7.2 stable (`ed1daf0bf`). GL Compatibility and Jolt Physics are preserved. No addon, external audio, engine installation, extra level, extra playable character, environment rebuild, or enemy beyond Polar was introduced.

## Executive status and scope

This implementation extends the working survival game with a distinctive warm BOING HUD, five-slot inventory, radial selection, three purchasable weapon families and their upgrades, seven pickup identities, temporary powers, intentional Amor activation, Tacos Don Plomazo, and budgeted Polar integration. MatchController continues to own match state, lives, timer, score and credits. The ten-minute survival flow remains intact.

Functional regression evidence is recorded below. Native procedural art is visibly simpler than the supplied production boards: this is a material visual limitation, not a claim of exact reference fidelity. A full unassisted ten-minute human acceptance session and export validation remain outstanding. The implementation should be reviewed against those limitations before production art acceptance.

## Baseline before edits

The working tree and diff were clean. AGENTS.md, project settings, main/player/UI scenes, MatchController, SurvivalDirector, SpawnManager, ObjectiveDirector, navigation, weapon/projectile code, first-aid purchase code, health supplies and Beta test helpers were inspected. Both existing tests ran before modifications:

- `beta_0_1_smoke.gd`: **103 checks, zero failures**.
- `beta_gameplay_audit.gd`: **148 checks, zero failures**.

Logs: `.godot/production_v2_baseline_smoke.log` and `.godot/production_v2_baseline_gameplay.log`.

## Visual authorities

All nine requested images were visually inspected before edits. The seven new authorities are actually supplied under `docs/references/production2/`, rather than `production_v2/`:

- `docs/references/mango/mango_sheet_final.jpg`
- `docs/references/enemies/pepsin/pepsin_sheet.png`
- `docs/references/production2/hud/hud_gameplay_master.png`
- `docs/references/production2/hud/hud_states_master.png`
- `docs/references/production2/hud/weapon_selector_master.png`
- `docs/references/production2/weapons/mango_weapons_master.png`
- `docs/references/production2/pickups/pickups_powerups_master.png`
- `docs/references/production2/enemies/polar_sheet.png`
- `docs/references/production2/shop/tacos_don_plomazo_master.png`

The reference directory has `.gdignore`: two supplied HUD files carry `.png` names but contain JPEG data, which image viewers read but Godot's PNG importer rejects. The authority files were preserved without rewriting or renaming them. Runtime UI uses independent derivatives in `assets/ui/`, so references do not need to be exported. PRO icons are rendered from the actual authored weapon models; they contain no board annotations. Original Mango and Pepsín visual source assets remain unchanged.

## HUD architecture and visual changes

`scenes/ui/hud.tscn` now hosts `production_hud.gd`. It builds anchored Control regions with HBox/VBox/Margin/Panel containers and shared `production_theme.gd` styles. The former `survival_status` endpoint is retained as a small compatibility bridge for MatchController's existing bind call. No money, ownership or weapon logic lives in the HUD.

Top-left: approved Mango portrait derivative, HP text, animated health bar, heart count. Top-center: compact timer plaque and objective. Top-right: score, kills, credits and separate transient credit-gain text. Bottom-left: five quick slots. Bottom-center: Amor meter and F control reminder. Bottom-right: current weapon and ammunition. Center: outlined crosshair with short gold hit confirmation. Context prompts are transient near the lower focus; objective transitions use a short backed toast.

Compared with Beta: dark translucent debug-like panels are replaced with warm brown framing, black outlines, fruit-green health, gold selected states, a Mango portrait, weapon icons, PRO markers, lock/ammo states, stronger typography and a radial menu. The timer no longer shares an opaque panel spanning most of the screen. Controls were rendered at 1280×720, 1152×648 and 960×640; shop/radial were also rendered at 960×640.

## HUD states

- Damage: existing restrained edge response plus red portrait response, HP update and short warning.
- Low HP: 25 or below, red health fill, PELIGRO text and restrained text pulse.
- Healing: animated HP fill, green portrait response and actual restored-HP message for discrete heals.
- Credits: independent green gain text under currency; spending cannot masquerade as a gain.
- Life loss: remaining hearts plus existing life-loss notice; no reward is granted by this event.
- Respawn protection: explicit REAPARICIÓN countdown, separate from Veladora.
- Zone change: transient backed toast and current objective update.
- Final minute: red pulsing timer and urgent final objective; final-minute audio hook.
- Powers: named active statuses and native-model icons with seconds remaining; gold/cool-blue/magenta ground aura for Veladora/Hielo/Amor.
- Hit confirmation: brief gold crosshair for real projectile/area hits.

Gameplay animation and durations use pausable delta. HUD's always-processing modal input path explicitly freezes its gameplay feedback while the tree is paused. Health interpolation also freezes during pause.

## Weapon architecture

`weapon_definition.gd` Resources in `resources/weapons/` describe id, presentation key, behavior, names, description, damage, PRO damage, cooldown, speed, range, radius, ammunition, price, upgrade price and availability. `arsenal.gd` owns per-match selected slot, ownership, PRO flags, ammunition and cooldown. Definitions are catalogue data; mutable inventory is separate. Purchase validation runs in the arsenal and spends MatchController's credits synchronously.

The existing Resortera script, launch socket, loaded mango, FPS/TPS visual and swept projectile remain in place. Its physics firing path is gated when another weapon is selected and receives temporary buff multipliers. New throws share `arsenal_projectile.gd`, with boomerang, ballistic area and straight explosive behaviors. `combat_effect.gd` provides finite-lived impact rings/trails and bounded fixed-rate salsa damage. Decorative geometry has no physics bodies.

### Final weapon stats

| Slot / weapon | Base / PRO damage | Cooldown | Speed | Range / lifetime | Area radius | Ammo | Base / upgrade credits |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 Resortera de Mango | 25 | 0.3333 s | 24 m/s | 100 m aim; existing 4 s projectile lifetime | — | Infinite | Starter / — |
| 2 Chancla de la Jefa → de la Abuela | 35 / 50 per valid pass | 1 s | 15 / 18.75 m/s; return ×1.3 | Turns after 0.7 s; guaranteed cleanup by 6 s | 0.6 m sweep radius, PRO ×1.2, plus target capsule | Infinite once owned | 500 / 1000 |
| 3 Molcajete con Habanero → Infernal | 90 / 125 center | 1.75 s | 12 m/s horizontal target cadence | 22 m bounded aimed arc, gravity 9.8 | 3 / 4.2 m | 4 maximum/start | 600 / 1200 |
| 4 Nopal (Trampa) | Unavailable | — | — | Reserved architecture only | — | — | Not sold |
| 5 Cuete de Feria → Komodo 3000 | 120 / 180 center | 2 s | 24 m/s | 80 m aim description; 6 s hard projectile cleanup | 4 / 5.6 m | 3 maximum/start | 700 / 1500 |

Explosions fall linearly from 100% center damage to 30% at the radius edge and respect world occlusion. Infernal additionally leaves a four-second salsa hazard: 10 damage every 0.5 seconds to enemies in its radius. The current hazard uses radial proximity on the floor; it does not simulate fluid spread. Chancla uses swept segment-versus-enemy-capsule distance and one hit per target per pass, with world occlusion checks. It clears the hit set only on return. Its return may recover through geometry rather than become permanently stranded.

PRO preserves the family's ammunition capacity and remaining rounds. It cannot be purchased before the base, cannot charge twice, and updates the owned family rather than adding an independent weapon. Resortera never consumes finite ammo. Huacal refills every owned finite-ammo family by ceil(50% max), capped at max; it cannot be wasted if every finite-ammo family is already full.

## Selection and input mappings

| Action | Input |
| --- | --- |
| Move | WASD |
| Jump | Space |
| Sprint | Left Shift |
| Fire/use | Left mouse, hold to repeat |
| FPS/TPS | V |
| Interact/shop | E |
| Select family | 1–5 |
| Previous owned weapon | Q or wheel up |
| Next owned weapon | Wheel down |
| Radial selector | Tab, then mouse hover/click or EQUIPAR; Tab/Esc closes |
| Activate Amor | F |
| Pause | Esc |
| Retry terminal result | R or button |

Production input audit checks all these actions for overlapping physical keys/buttons. Tab is handled before GUI focus traversal so it reliably opens/closes the radial. Modal close applies a short firing grace through the existing cooldowns. Selection skips unowned families when cycling. Number keys select during gameplay; wheel selection is mouse-driven.

## Shop architecture and prices

The physical Tacos Don Plomazo occupies the former first-aid footprint `(3, 0, -4)`. Its existing scene node name `healing_station` is retained for compatibility, but it instantiates `tacos_don_plomazo.tscn`, not the old generic service stand. It has a solid counter, navigation obstacle, slatted wood, backed menu boards, vendor, moustache/cap/apron, small tacos/salsas, hanging colored paper and decorative bulbs. No per-bulb light cost or real-world branding.

Within 3.3 m with world line of sight and a valid live match, E opens the shop. Opening uses MatchController.pause, hides its pause panel and releases the mouse. The paused tree prevents AI, damage, movement, timer and effect progression. Closing resumes the same match and mouse capture. Esc closes the modal through MatchController's input handling without leaving a second pause state behind.

ARMAS contains Chancla 500, Molcajete 600 and Cuete 700. MEJORAS contains Abuela 1000, Infernal 1200 and Komodo 1500. ITEMS is a future category with an explicit availability message, not purchasable fake stock. The detail panel shows visual, role, damage/range/cadence bars, ammunition, price and current state. DISPONIBLE, COMPRADO, EQUIPADO, SIN CRÉDITOS, MEJORABLE and PRO ADQUIRIDA are represented. Confirmed transactions show ¡GRACIAS, JOVEN! through the button path. The arsenal revalidates modal type, shop proximity/visibility, match state, base ownership, balance and duplicate upgrades. Only spendable credits decrease; total score is preserved.

## Pickups and temporary powers

`pickup.gd` provides reusable Area3D collection (layer 0, mask 2), one sphere, bob/rotation, nearby label, used guard, valid-benefit checks and collection signal. Existing authored health supplies retain their proven healing/overlap contract and use the new Botiquín model. `prop_factory.gd` shares native meshes/palettes for held props, projectiles, pickup presentation and shop detail. `power_state.gd` owns pausable durations and combat multipliers. Six additional authored pickups complement the eight health supplies. ¡Estoy Happy! has one authored occurrence per match; no random drop framework was introduced.

| Pickup | Value / duration | Waste rules |
| --- | --- | --- |
| Botiquín de la Abuela | +30 HP, capped at max | Rejected at full HP/dead |
| Veladora | No incoming damage for 5 s | Recollect refreshes duration; distinct from respawn protection |
| Bolsa de Hielo | Incoming damage ×0.5 for 8 s | Recollect refreshes |
| Huacal con Frutas | Ceil(50% max) to each owned finite-ammo family | Rejected if no family can gain rounds |
| Chile | Damage ×1.25 and cadence ×1.15 for 10 s | Temporary, stacks multiplicatively with Amor, never replaces PRO |
| Amor del Pueblo | +25 meter | Rejected when full or during active Amor |
| ¡Estoy Happy! | 8 s: movement ×1.15, cadence ×1.2, regeneration 1.5 HP/s | No damage multiplier; distinct mobility/regen identity |

Powers expire on pausable simulation time. Life restoration clears temporary effects, preserves the Amor meter/inventory/economy and grants the existing separate 2.75 s respawn protection. Death does not grant credits.

## Amor del Pueblo

Every valid combat kill adds 10 meter, up to 100. A pickup can add 25. Hot Zone score bonuses do not charge it by themselves. At 100, F intentionally activates ¡A DARLE, CABRÓN! for eight seconds and resets the meter to zero. Activation never happens automatically. While active: damage ×1.35, movement ×1.20, incoming damage ×0.70 and cadence ×1.20. Meter cannot charge or re-trigger during the active interval. Power combinations multiply their independent effects.

## Polar architecture and integration

`polar.gd` is a CharacterBody3D with separate `polar_visual.gd`. The visual uses a lean white silhouette, red ribbed sweater with front/back snowflake band, eyebrows, muzzle/nose/canines, large articulated paws, fingers, dark claws, splayed feet and tail. It is approximately 1.8 m tall. Native idle/locomotion, anticipation, strike, hit and death presentation use delta time. Materials include subtle knitted surface variation. Pepsín's behavior/visual source is unchanged.

Stats: 220 HP; 4.2 m/s; melee reach 1.9 m; initial anticipation 0.65 s; claw 30 damage; every third committed attack is a three-strike combo of 15 per strike with 0.32 s follow-up anticipation and 0.5 s recovery. The final strike sets attack cooldown to 1.5 s plus recovery. Follow-ups require the player to remain close. Each actual strike revalidates range, forward arc and world line of sight. No stun-lock or roar attack is applied. Optional roar remains future work; no second enemy was added.

Polar follows the existing planar AStar routes and physical world collision. Its layer is 4, mask 7, matching enemy conventions. Kill reward is resource-configured 300 score and credits, plus the existing 50 Hot Zone bonus if applicable. SurvivalDirector registers its enemy definition with weight 0.35, budget cost 4, minimum elapsed 180 s and maximum four active Polar. Pepsín costs 1. Existing stage caps remain 8/10/14/18/20/22, now also limiting budget; intervals/batches remain the existing progression. No unrelated script randomly spawns Polar. The stress fixture intentionally seeds 22 bodies including three Polar, exceeding normal budget to exercise mixed rendering.

## Audio hooks

`audio_hooks.gd` exposes `cue_requested(cue, position)` and forwards weapon fire/equip, purchases, pickups, damage, low-health entry, life loss, Amor activation, final minute and Polar attack events. Future roar audio can use the same hook when an optional roar behavior exists. No final audio assets or downloaded/copyrighted sounds were fabricated. Hooks are silent until connected to approved audio playback.

## Rendered review and corrections

`production_visual_review.gd` produces the ignored `.godot/production_v2_review/` gallery. The review covers FPS/TPS, damage, low HP, healing, final minute, quick slots, radial, equipped weapons, exterior, shop, purchase/PRO, all seven pickup models, Amor/power statuses, life loss/protection, three HUD/pause resolutions, minimum-size shop/radial, Polar front/side/back/anticipation, mixed combat, victory and defeat. `production_horde_review.gd` adds the stress image.

Corrections driven by direct image inspection:

1. Fixed quick-bar anchors that moved the bar into the upper-left on resize.
2. Corrected the Mango portrait crop and reimported the derivative.
3. Reduced the timer background from a wide opaque strip to a compact plaque.
4. Backed short notices to prevent world signs interfering with readability.
5. Separated credit gains from combat/healing notices; life loss awards no currency.
6. Added stronger font weight, gold selection, HP danger color and positive portrait response.
7. Replaced annotated PRO sheet crops with clean offscreen model renders; corrected the offscreen viewport update mode after a transparent-icon review failure.
8. Added wood detail, sign clearance, counter slats/tacos and more readable shop lettering.
9. Increased Polar hand size, widened stance, added canines and front/back knitted motifs.
10. Reworked the ice pickup's round top into a tied/faceted bag and the solid heart into an open cut-paper silhouette.
11. Corrected aimed Molcajete trajectory after a real close-target test exposed overshoot.
12. Corrected Chancla sweep to use enemy capsules rather than a single chest point; verified exactly one hit per pass.
13. Fixed a missing credit-label initialization found by an early performance run. That erroneous sample was discarded.

## Automated validation and artifacts

Final suite results and the exact manifest are appended after the final validation run. Tests are opt-in under `scripts/test/` and excluded from export. The gameplay/resource audit loads the expanded scripts/resources. The structure audit verifies runtime NodePaths, signal callables, collision conventions, absence of production test scripts and unique production inputs. Static resource/UID audit records `.godot/production_static_audit.json`. `git diff --check` is required clean.

Useful rerun commands, using the installed console executable:

```powershell
$engine = 'D:/heezl/Escritorio/godot/Godot_v4.7.2-stable_win64_console.exe'
& $engine --headless --path . --script res://scripts/test/beta_0_1_smoke.gd
& $engine --headless --path . --script res://scripts/test/beta_gameplay_audit.gd
& $engine --headless --path . --script res://scripts/test/production_combat_audit.gd
& $engine --headless --path . --script res://scripts/test/production_structure_audit.gd
& $engine --path . --script res://scripts/test/production_combat_audit.gd
& $engine --path . --script res://scripts/test/production_visual_review.gd
& $engine --path . --script res://scripts/test/production_horde_review.gd
```

For rebuilding derivatives: run `production_extract_icons.gd`, then `production_render_icons.gd` with rendering enabled, then an editor import. The extractor intentionally reads source images by filesystem; its load-from-file warnings concern the opt-in tool, not runtime export dependencies.

## Known limitations and remaining placeholders

- The native-mesh weapons, pickups, vendor, Polar and simple UI surfaces do not reproduce the full sculpting/material richness of the production sheets. This fidelity gap remains subject to art acceptance; no exact-match claim is made.
- Nopal is intentionally reserved/locked. ITEMS has no purchasable inventory in this milestone. No optional Polar roar/stagger was implemented.
- Final audio is not present. Hooks exist; no sound-design acceptance is claimed.
- Inventory is per match, not a persistent account inventory. Restart resets it and all resources.
- The approved Resortera's original physics/visual script remains authoritative; its catalogue entry mirrors the default stats and should be updated with that script if future balance changes.
- New explosive/throw origins use Mango's upper-body launch point, while the preserved Resortera uses its authored visual socket. New FPS/TPS hand posing is procedural and simpler than a dedicated rigged animation set.
- Effects are lightweight native rings/trails, not final authored particle/animation assets. Infernal hazard proximity does not perform detailed fluid occlusion/spread.
- Navigation remains planar, including Polar. No multi-level navigation rebuild was attempted.
- System bold fonts fall back according to the host's installed fonts. Layouts were reviewed on this Windows machine, not every platform/font set.
- The 20 s performance fixture is a short stress sample, not a ten-minute soak or hardware guarantee. Individual slower frames remain above the 16.67 ms target.
- Existing dormant Beta HUD/service files remain in the repository but are not instantiated by production. The legacy service method is retained; the active E path and stand are the new shop.
- Standalone export was not produced; matching export templates were unavailable in the baseline environment. Export metadata was updated to 0.2.0-dev / Production V2 without downloading templates.

## Manual acceptance checklist

Leave these unchecked until a human performs the acceptance session:

- [ ] Launch in Godot 4.7.2; enter the store and complete a full ten-minute survival run.
- [ ] Move, sprint, jump, aim and switch FPS/TPS in every existing combat zone.
- [ ] Read HP/hearts/timer/objectives/economy at all three target resolutions during combat.
- [ ] Verify restrained damage, low-HP, healing, life loss and distinct respawn/Veladora protection.
- [ ] Earn credits, approach Tacos Don Plomazo, use E, buy all bases, reject unaffordable upgrades, buy PRO and equip.
- [ ] Use Q, wheel and 1–5; open/close Tab and Esc repeatedly with no stuck pause/mouse state or accidental firing.
- [ ] Throw Chancla through a group and watch its return; test around walls/corners.
- [ ] Use Molcajete at short/long ranges and Infernal salsa on moving groups.
- [ ] Use Cuete/Komodo, deplete ammunition and refill with Huacal; verify Resortera remains infinite.
- [ ] Collect all seven pickup types, including full-health/full-ammo rejection.
- [ ] Charge Amor by combat, activate F intentionally and observe expiration; compare Happy's mobility/regen identity.
- [ ] Observe Polar entering after three minutes, readable anticipation/three-hit combo, avoidance, death/reward and mixed pressure.
- [ ] Pause with projectiles/powers active, adjust settings, resume, lose lives, reach defeat/victory and retry cleanly.
- [ ] Compare new art directly with all approved sheets and decide production visual acceptance.
- [ ] Validate an exported Windows build when matching templates are available.

## Final validation record

| Suite | Checks | Failures |
| --- | ---: | ---: |
| Existing survival smoke, adapted for weapon-shop transaction | 102 | 0 |
| Existing gameplay/resource audit | 177 | 0 |
| Production combat audit, rendered including mouse capture | 103 | 0 |
| Runtime structure/input/signal/collision audit | 518 | 0 |
| **Total assertions across these suites** | **900** | **0** |

The headless production combat suite also passed 102 checks before the final credit-feedback assertion was added; the rendered final suite includes that additional assertion. Counts describe executed assertions, not 900 independent gameplay scenarios. The smoke suite changed from 103 baseline assertions to 102 because the old healing purchase assertions were replaced with the production weapon-shop path; survival/lives/victory/defeat/restart checks remain.

All final smoke, gameplay/resource, rendered combat, runtime structure, visual capture and editor import logs were checked for errors and were clean. `git diff --check` passed. No production node references a test script. Runtime signal callables and exported NodePaths were resolved by the structure suite. No conflicting production key/button bindings were found.

Static audit: **186 resource paths, 1480 ExtResource/SubResource uses, 72 UIDs, zero errors**.

### Final performance sample

PRODUCTION_HORDE: 1200 frames / 20 s; mean 16.68 ms (60.0 FPS); p95 20.35 ms; peak 22 enemies / 9 projectiles; peak 5 effects; mean process 18.69 ms / physics 6.17 ms; peak 3202 draw calls

Machine: NVIDIA GeForce GTX 1650 Max-Q, OpenGL Compatibility, 1280?720, 60 FPS cap, 20 seconds. The fixture seeds three Polar among 22 enemies and fires repeated Cuetes, with test-only invulnerability. The 22-body mixed fixture deliberately exceeds normal cost budget. `TIME_PROCESS` and `TIME_PHYSICS_PROCESS` are engine monitor samples, not mutually exclusive wall-frame components or isolated GPU timings. High draw-call volume is observed; a detailed GPU/CPU profiler breakdown was not captured, so the dominant bottleneck is not conclusively isolated. The p95 shows slower frames above the 16.67 ms target. The new visuals are a small part of an existing detailed store and horde; no future environment redesign was performed as a performance shortcut.

### Screenshot index

45 images in `.godot/production_v2_review/` (ignored local QA artifacts):

```text
01_fps.png
02_tps.png
03_damage.png
04_low_health.png
05_healing.png
06_final_minute.png
07_radial.png
08_shop.png
09_purchase.png
10_pro.png
11_equipped_1.png
11_equipped_2.png
11_equipped_4.png
12_amor.png
12_life_lost.png
12_power_candle.png
12_power_chile.png
12_power_happy.png
12_power_ice.png
12_respawn_protection.png
13_hud_1152.png
13_hud_1280.png
13_hud_960.png
14_pause_1152.png
14_pause_1280.png
14_pause_960.png
14_shop_960.png
14_wheel_960.png
15_shop_exterior.png
16_pickup_ammo.png
16_pickup_candle.png
16_pickup_chile.png
16_pickup_happy.png
16_pickup_health.png
16_pickup_ice.png
16_pickup_love.png
17_pickups.png
18_polar_front.png
19_polar_side.png
20_polar_back.png
21_polar_attack.png
22_mixed_combat.png
23_victory.png
24_defeat.png
25_horde.png
```

### Exact created-file manifest

82 created files, including generated import/UID sidecars:

```text
assets/ui/mango_portrait.png
assets/ui/mango_portrait.png.import
assets/ui/power_candle.png
assets/ui/power_candle.png.import
assets/ui/power_chile.png
assets/ui/power_chile.png.import
assets/ui/power_happy.png
assets/ui/power_happy.png.import
assets/ui/power_ice.png
assets/ui/power_ice.png.import
assets/ui/power_love.png
assets/ui/power_love.png.import
assets/ui/weapon_0.png
assets/ui/weapon_0.png.import
assets/ui/weapon_1.png
assets/ui/weapon_1.png.import
assets/ui/weapon_2.png
assets/ui/weapon_2.png.import
assets/ui/weapon_3.png
assets/ui/weapon_3.png.import
assets/ui/weapon_4.png
assets/ui/weapon_4.png.import
assets/ui/weapon_pro_1.png
assets/ui/weapon_pro_1.png.import
assets/ui/weapon_pro_2.png
assets/ui/weapon_pro_2.png.import
assets/ui/weapon_pro_4.png
assets/ui/weapon_pro_4.png.import
docs/production_v2_combat_ui.md
docs/references/production2/.gdignore
resources/enemies/polar_definition.tres
resources/production/market_surfaces.gdshader
resources/production/market_surfaces.gdshader.uid
resources/weapons/chancla.tres
resources/weapons/cuete.tres
resources/weapons/molcajete.tres
resources/weapons/nopal.tres
resources/weapons/resortera.tres
scenes/enemies/polar/polar.tscn
scenes/game/tacos_don_plomazo.tscn
scripts/enemies/polar/polar.gd
scripts/enemies/polar/polar.gd.uid
scripts/enemies/polar/polar_visual.gd
scripts/enemies/polar/polar_visual.gd.uid
scripts/game/production/audio_hooks.gd
scripts/game/production/audio_hooks.gd.uid
scripts/game/production/combat_effect.gd
scripts/game/production/combat_effect.gd.uid
scripts/game/production/pickup.gd
scripts/game/production/pickup.gd.uid
scripts/game/production/power_state.gd
scripts/game/production/power_state.gd.uid
scripts/game/production/prop_factory.gd
scripts/game/production/prop_factory.gd.uid
scripts/game/production/tacos_shop.gd
scripts/game/production/tacos_shop.gd.uid
scripts/projectiles/arsenal_projectile.gd
scripts/projectiles/arsenal_projectile.gd.uid
scripts/test/production_combat_audit.gd
scripts/test/production_combat_audit.gd.uid
scripts/test/production_extract_icons.gd
scripts/test/production_extract_icons.gd.uid
scripts/test/production_horde_review.gd
scripts/test/production_horde_review.gd.uid
scripts/test/production_render_icons.gd
scripts/test/production_render_icons.gd.uid
scripts/test/production_structure_audit.gd
scripts/test/production_structure_audit.gd.uid
scripts/test/production_visual_review.gd
scripts/test/production_visual_review.gd.uid
scripts/ui/production_hud.gd
scripts/ui/production_hud.gd.uid
scripts/ui/production_theme.gd
scripts/ui/production_theme.gd.uid
scripts/ui/survival_hud_bridge.gd
scripts/ui/survival_hud_bridge.gd.uid
scripts/ui/weapon_wheel.gd
scripts/ui/weapon_wheel.gd.uid
scripts/weapons/arsenal.gd
scripts/weapons/arsenal.gd.uid
scripts/weapons/weapon_definition.gd
scripts/weapons/weapon_definition.gd.uid
```

### Exact modified-file manifest

15 modified existing files:

```text
export_presets.cfg
project.godot
scenes/characters/mango/player.tscn
scenes/environment/mega_abarrotera/mega_abarrotera.tscn
scenes/game/main.tscn
scenes/game/survival/match_controller.tscn
scenes/ui/hud.tscn
scripts/characters/mango/player_controller.gd
scripts/game/health_pickup.gd
scripts/game/survival/enemy_definition.gd
scripts/game/survival/match_controller.gd
scripts/game/survival/survival_director.gd
scripts/projectiles/projectile.gd
scripts/test/beta_0_1_smoke.gd
scripts/weapons/projectile_weapon.gd
```

### Files moved

None. Original visual authorities and existing Mango/Peps?n art remain at their original paths. Generated reference `.import` files created by this run were removed after adding `.gdignore`; no pre-existing user reference was deleted.
