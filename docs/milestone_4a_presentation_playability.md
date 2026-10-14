# Milestone 4A — presentation, survival playability and Mango boots

This pass resumes the existing project. It does not rebuild the survival mode or Mega Abarrotera layout. Mango's approved sheet remains the boot-design authority. No enemy, weapon, backpack, movement, projectile, damage, match-state or scoring redesign was made.

## Presentation

- Replaced oversized standalone store/zone/aisle/checkout text with smaller text backed by saved physical boards. Aisle and checkout boards have shared ceiling-hanger meshes. Mexican phrases remain; ordinary crate, sack, cooler and register labels now fit their fixtures.
- Reduced the title from font 200 / pixel size 0.026 to 64 / 0.010. Other standalone signs use 32–40 / 0.006–0.008. Repeated module lettering uses 0.006 pixels per unit. Price tickets are smaller still.
- Objective labels are short zone names, font 32 / pixel size 0.012, depth-tested and visible within 45 m. The slimmer gold beacon remains visible through obstacles for guidance; full objective wording stays in the HUD. Its label does not render through walls.
- Main ambient energy is 0.60, daylight 0.72, warm store fills 0.80, cooler fill 1.0 and industrial fill 0.70. Floor and wall colors are more distinct and less pale. Commercial lamps, refrigerator panels and register screens have lower emission. No extra dynamic lights were added.
- Six reusable countertop offer displays contain small huacales, colorful fictional snack packages, supported offer placards and two shared MultiMesh batches each. Thirty-two tiny price tickets attach to the existing shelf edges. Grain labels have boards and stakes. Existing papel picado, piñatas, garrafones, carts, pallets, huacales, returnable crates and diablitos are retained.
- All new retail dressing is non-colliding and sits on existing fixtures. Ground collision footprints, zone bounds, objective/spawn locations, routes and cover remain unchanged.

## Temporary health supply

`scenes/game/health_pickup.tscn` is a saved, editor-visible cream/green supply kit with two-sided crosses, handle, floor marker and a small +30 label. It bobs, rotates and gently pulses in scale. No inventory, random drops or respawn system was introduced.

Collection calls the existing player's `heal(30)` method. That method caps HP at max HP and emits `health_changed`, so the current HUD updates through its existing signal connection. The pickup emits `collected(player, restored_hp)` with the actual restored amount, disables monitoring and disappears once. Full-health players leave it available; dead players cannot collect. Overlap checking lets an already-overlapping full-health player collect after taking damage. Its animation and collection pause with gameplay. Restart recreates all authored kits.

Eight authored instances live under `mega_abarrotera/health_pickups`; positions are world X/Z in meters, all at floor height:

| Node | X | Z |
| --- | ---: | ---: |
| salud_cajas_oeste | -48 | -9 |
| salud_cajas_este | 48 | -9 |
| salud_pasillo_cruce | 0 | -35 |
| salud_pasillo_sur | 20 | -59 |
| salud_refrigeradores | -57 | -31 |
| salud_frutas | 55 | -68 |
| salud_bodega | 20 | -68 |
| salud_patio | -40 | -88 |

## HUD

The existing health/camera/weapon bindings remain unchanged. Saved controls now place camera mode, HP and bar at top left; timer and wrapped objective at top center; points and kills at top right; weapon/ammo at bottom left. Smaller 14–28 px text, reduced outlines and subtle translucent backing replace the oversized presentation. The gameplay debug footer is hidden. Pause/results still use their existing interactive overlay.

## Boots only

`mango_appearance.build_boot()` delegates to a focused native `mango_boot.gd` helper. Other appearance-building functions are unchanged. The boot now has a tapered oval outsole, a separate light welt, rounded heel/shaft and padded collar, tan toe/vamp, sloping tongue, crossed laces, restrained sole grooves and quarter/heel stitching.

The sole is an enclosed native ArrayMesh with bevels, a shallow arch and toe rocker. Its plan-view rounding is independent of its thin vertical height, avoiding the old near-square rounded-box footprint. The heel is narrower than the forefoot, and the length/width are slightly reduced. Existing leg pivots, shin/ankle geometry, movement animation and FPS body hiding remain intact. No backpack, face, helmet, glove or resortera changes were made.

## Files created

- `scripts/characters/mango/mango_boot.gd`
- `scenes/environment/mega_abarrotera/modules/offer_display.tscn`
- `docs/milestone_4a_presentation_playability.md`
- `docs/milestone_4_survival_core.md` — records the existing core and completed static review.

## Files modified in this pass

- `scripts/characters/mango/mango_appearance.gd`
- `scripts/environment/mega_abarrotera/mega_abarrotera.gd`
- `scripts/game/health_pickup.gd`
- `scripts/ui/survival_hud.gd`
- `scenes/game/main.tscn`
- `scenes/game/health_pickup.tscn`
- `scenes/ui/hud.tscn`
- `scenes/ui/survival_hud.tscn`
- `scenes/environment/mega_abarrotera/mega_abarrotera.tscn`
- `scenes/environment/mega_abarrotera/objective_beacon.tscn`
- `scenes/environment/mega_abarrotera/modules/sign.tscn`
- `scenes/environment/mega_abarrotera/modules/bottle_crate.tscn`
- `scenes/environment/mega_abarrotera/modules/checkout_module.tscn`
- `scenes/environment/mega_abarrotera/modules/costales.tscn`
- `scenes/environment/mega_abarrotera/modules/fridge_bank.tscn`
- `scenes/environment/mega_abarrotera/modules/huacal.tscn`
- `scenes/environment/mega_abarrotera/modules/pallet_stack.tscn`
- `scenes/environment/mega_abarrotera/modules/produce_display.tscn`

No files were moved or deleted in this pass. Earlier milestone changes were already present in the dirty Git working tree and were preserved.

## Validation and limits

Godot is not available on PATH. Nothing was installed. Validation is static, not a Godot parser, runtime or rendered visual test.

- Resource graph, scene parents, resource identifiers and literal/default NodePaths pass: 108 resource paths and 179 paths checked.
- All 112 navigation obstacle footprints exactly match the pre-pass snapshot. The offline grid reconstruction connects all 5,626 free cells to the player; 38 spawn markers and objective positions remain reachable.
- Eight pickups have clear 0.85 m collection radii and connected ground routes.
- All 141 expanded production world labels have bounded font/pixel sizes and depth testing; serialized offer MultiMesh buffers have the correct length.
- Numerical reconstruction of both sole layers confirms finite vertices, closed caps, nondegenerate triangles and consistent Godot clockwise winding. This is not a render of the boots.
- Hash comparisons preserve core controllers, Pepsín, settings, cameras, projectiles, weapons, player movement, Mango posing and backpack. Comparing appearance functions confirms non-boot art is unchanged.
- Existing source guards and offline state models cover the official phase boundaries, 600-second timer, pause, scoring, terminal exclusivity and deferred restart. No core-script changes were required.

Environment props, flat-color packaging, native boot surfaces, supply-kit art and HUD remain stylized temporary presentation. Lighting/exposure, actual boot intersections during motion, visual framing, ten-minute difficulty balance and final-minute performance need runtime review.

## Manual Godot checklist

1. Open/import in Godot 4.7; check the Output panel for script/resource errors. Run the configured main scene and inspect zone/sign/pickup nodes in the editor.
2. Start outside the entrance in READY. Confirm timer stays 10:00; enter once and verify spawning/timer begin once. Visiting the rear exit must not win.
3. Play a full ten-minute match. Check zone changes at 08:30, 07:00, 05:30, 04:00, 02:30 and 01:00; confirm the final objective and compact world beacon match the HUD.
4. Check all zones in FPS/TPS: signage scale/supports, color contrast, refrigerator/bodega/patio lighting, aiming, camera clearance and absence of intrusive text. Inspect HUD at normal and smaller window sizes.
5. Confirm Pepsín spawning is hidden and suitably distant, paths go around shelves/walls, horde spacing remains usable, and damage/projectile feedback works in both camera modes.
6. Verify +100 per kill, +50 while Mango is in the active zone, kill count, and +500 only for a participated phase.
7. At full HP, overlap a kit: it should remain. At 40 HP it should restore 30; at 80 HP it should stop at 100. Verify HUD immediately updates, collection occurs once, kits do not block paths, and no collection happens while paused/dead.
8. Pause/resume in READY and PLAYING: timer, spawns, AI, movement, fire and pickup bob/rotation must stop and resume the same match. UI remains usable.
9. Let Mango die: only DEFEAT, no continued damage/spawns, released mouse and correct results. Restart returns to a clean READY state, with all kits restored and no old enemies/timers.
10. Survive to 00:00: only VICTORY, combat disabled, correct score/kills/10:00 result, usable restart/exit. Restart again and check clean state.
11. Inspect boots from front, side and rear in TPS: walk, sprint, jump, aim, fire and take damage. Check rounded toe/heel, welt, sole contact, ankle joins and no distracting seams/clipping. Confirm FPS still hides body/boots and shows resortera/pouch/ammo correctly.
12. Review frame time/draw calls during the final minute, especially looking down multiple stocked aisles; tune presentation only if measurements identify a problem.
