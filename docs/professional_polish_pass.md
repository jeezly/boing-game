# BOING professional polish pass — 2026-11-04

The project runs in Godot **4.7.2**, using **GL Compatibility and Jolt**. Existing uncommitted work was preserved. No addons, optional weapon, commits or exports were added.

## State at the interruption

Already present: per-match arsenal/shop/HUD, partial ammunition refill, the 30-second effect calculations, tequila ammo exemptions, Chancla tuning, enemy hit-overlay component and removal of the live Amor meter/charging hook. These were not fully validated.

Still incomplete or incorrect: missing pickup-burst script, pickup feedback executing outside the successful-collection branch, damaged accented strings, no melee, no drunken camera movement, yellow/short objective beacons, old tests calling removed Amor APIs, and no substantial environment changes from this pass. Tint overrides were not the materials actually used by the meshes, and instance transparency did not work as intended in Compatibility.

## Completed after resuming

- Fixed those integration problems and verified the actual bound materials in tests and screenshots.
- Right-click manotazo: 32 base damage, 2.35 m range, 0.55 s cooldown, forward cone, obstruction checks, knockback, FPS glove/forearm motion and TPS left-arm motion. Keeps weapon handling independent.
- Explicit red hit confirmation on both Pepsín and Polar, lasting about 0.16 s. Pepsín's existing reaction animation no longer erases the overlay during that interval.
- Huacales refill **all owned limited-ammo weapons** by half their maximum, rounded up, without exceeding capacity. Full reserves do not consume them. Huacales respawn after 25 s.
- Moved inaccessible Hielo, Chile and ammo placements into clear lanes. Added ammo supplies in fruits and patio; existing supplies cover central aisles and bodega.
- Pickup halos, floating pickup animation, colorful bursts, healing crosses, pickup/expiration notices and persistent HUD timers.
- Removed live Amor gameplay, charging, activation, HUD meter and F action. Updated old test/review fixtures. Historical reference sheets and the unused old icon remain as source material, not active gameplay.

| Power | Behavior | Duration |
|---|---|---|
| Bolsa de Hielo | 50% incoming damage, subtle cool tint, blue aura | 30 s |
| Chile | ×1.5 damage, ×1.3 fire rate, warmer Mango skin, short ear puffs, red aura | 30 s |
| Veladora | Material alpha 0.42, ghost silhouette, enemy detection limited to 3.5 m, lavender aura | 30 s |
| YA SE ME CALENTÓ EL HOCICO | Invulnerable, infinite ammo even with zero reserve, ×1.35 damage, ×1.6 fire rate, restrained camera roll/offset, orange aura | 30 s |

Repeated collection refreshes to 30 seconds; it does not accumulate duration. Different powers coexist. Pause freezes gameplay timers. Life loss clears the effects. Veladora does not grant invulnerability; pre-existing projectiles can still hurt Mango.

| Weapon tuning | Base | Upgraded |
|---|---|---|
| Chancla | 21 m outgoing reach, speed 21, cooldown 0.78 s, damage 35 | 29.4 m outgoing reach, speed 26.25, damage 65, cooldown about 0.64 s |
| Molcajete | Damage 90, cooldown 1.45 s, 4 ammo | Damage 150, ×1.4 blast radius, cooldown about 1.19 s, existing salsa hazard |
| Cuete / Komodo 3000 | Damage 120, cooldown 1.65 s, 3 ammo | Damage 220, ×1.4 blast radius, cooldown about 1.35 s |
| Resortera | Existing infinite reserve and projectile aiming retained | Benefits from Chile/tequila multipliers |

Chancla returns by traveled distance, rather than the previous fixed 0.7-second timeout. Outgoing and returning passes retain separate hit tracking. Explosive damage still uses distance falloff and wall checks.

## Environment changes

- Replaced repeated generic shelf filler with families of printed packages, pillow bags, rolled-rim cans, shoulder/neck bottles and closures. Merchandise is grouped by brand with controlled gaps and small pose/scale variation.
- Added nine original packaging graphics. Raster labels avoid unsupported SVG text in Godot's SVG importer. UV direction was corrected after visual inspection.
- Industrial shelves now hold larger shipping cartons with tape and handling graphics, rather than stretched retail products.
- Produce tables now have separate mango, lime, corn, tomato, watermelon and poblano identities, partitions, stems/leaves and clear price cards.
- Corn has kernel patterning and folded husks. Granel has open rolled sack lips, bean/maize heaps, visible grains and scoops. Tiny grains use shared low-poly geometry.
- Checkout kickplates, recessed panels, belt rollers, scanner glass/line, bagging details and local-store signage.
- Wood grain, painted metal variation and soft fixture contact shading. Reduced the warm ambient wash and added directional form lighting.
- Added wall pilasters/plinths/trims, rear clerestory glazing, lamp housings, twin fluorescent tubes and their hangers. Added deliberate neighborhood/retornable/mayoreo signs.
- Ramp handrails, balusters and landing nosing complement the original raised route. Original physical bodies and navigation obstacles remain intact.
- Replaced all three disconnected broom pairs with a reusable broom whose bristles meet the floor and whose handle connects to its head. Placements sit beside existing fixtures/walls.
- Hot zones now have a **5.46 m diameter red floor ring**, animated red column/core **14.2 m tall** and distant labels. No extra real-time lights are required.
- Shared product MultiMeshes, cached fixture meshes and equivalent-material grouping control draw calls. Decorative microgeometry does not add navigation obstacles.

## Validation

Final automated suite with the **real OpenGL Compatibility renderer**, Godot 4.7.2:

| Audit | Checks | Failures |
|---|---:|---:|
| professional_polish_audit | 56 | 0 |
| production_combat_audit | 99 | 0 |
| production_structure_audit | 588 | 0 |
| environment_polish_audit | 68 | 0 |
| beta_0_1_smoke | 102 | 0 |
| beta_gameplay_audit | 215 | 0 |
| **Total** | **1128** | **0** |

The environment audit was rerun after the final art-only changes: 68 checks, zero failures. Final editor import also completed without script errors. `git diff --check` passed. Literal resource paths were audited; see `reviews/professional_polish/resource_audit.txt` for the final count.

Earlier headless runs passed their assertions but some scene reloads produced Godot dummy-renderer `material is null` diagnostics. These did not occur in the final real-renderer suite. They remain a headless-backend caveat, not a claim that the dummy renderer is clean.

Two review scripts captured **14 environment views and 27 gameplay/detail views**, followed by further corrections and recaptures. Inspected areas include checkout, aisles, drinks/coolers, produce/corn/granel, bodega/ramp, patio, ceiling, facade, broom placement, both enemy flashes, FPS/TPS, melee, healing and every power. Curated captures and before images are in `reviews/professional_polish/`.

Corrections driven by screenshots: missing SVG typography, inverted bottle labels, overly generic warehouse merchandise, ineffective material overrides, opaque Veladora, pink additive hot-zone rings, misplaced checkout details, and unstable review-camera orientation caused by captured desktop mouse motion.

## Performance and limits

Measured on this machine's **GTX 1650 Max-Q**, at **1280×720** with Compatibility:

- Static checkout, uncapped: latest sample **12.38 ms/frame (~80.8 FPS)**, **4846 draw calls**. Initial pre-environment-pass sample was 8.97 ms/frame, 5196 calls. The richer geometry/materials increase GPU cost despite fewer calls.
- Two 20-second mixed-horde runs, capped at 60: **54.5–58.0 average FPS**, **22.15–25.98 ms p95**, up to **22 enemies, 9 projectiles, 5 combat effects**. Latest mean physics time: **7.82 ms**. These samples are not a guarantee of locked 60 FPS on other hardware.
- The environment retains native stylized geometry; some distant repetition remains. Transparency can show layered internal parts in Compatibility. Added ramp rail details are visual; original collisions remain authoritative.
- No optional weapon or new recorded audio was added. Existing audio hooks remain available. Manual feel/comfort review, the complete ten-minute run and lower-spec hardware testing remain necessary acceptance steps.

## Exact manual acceptance checklist

1. Open `project.godot` in Godot 4.7.2 and press **F5**. Confirm no script/runtime errors in Debugger. Enter the store to start the ten-minute round.
2. Walk checkout → central aisles → coolers → fruits/granel → bodega → patio. Check routes, cover, shop interaction with **E**, collisions, clear sightlines and enemy pursuit. Inspect bottles/cans up close, corn husks/kernels, open grain sacks, signs, lamp hangers and the broom by the west checkout wall.
3. Use **V** to check both first- and third-person views. Aim/fire while walking and switching weapons with **1–5**, wheel/Q and **Tab**. Shop purchases/upgrades must still pause safely and preserve score versus spendable credits.
4. Right-click near Pepsín and Polar: confirm a responsive manotazo, glove/arm motion, damage, red flash, crosshair confirmation and modest knockback. Hold/spam right-click: no duplicate immediate damage. Try through a shelf/wall and outside ~2.35 m: no damage through cover or at long range.
5. Buy Molcajete/Cuete. Fire until empty; ensure empty weapons cannot fire. Collect a huacal at central **(0,0,-34)**, bodega **(-1,0,-69)**, fruits **(54,0,-69)** or patio **(-28,0,-65)**. Both owned limited weapons should refill, HUD should update, and full reserves should leave the pickup available. Return after 25 seconds to verify respawn.
6. Collect Hielo at **(11,0,-20)**. Check blue tint/aura and HUD timer, take damage, and confirm roughly half HP loss. After 30 seconds, normal damage and colors return.
7. Collect Chile at **(11,0,-48)**. Check warmer Mango, short puffs and attack improvement. Compare with/without it using Resortera and an explosive. Verify expiration after 30 seconds.
8. Collect Veladora at **(-2,0,-9)**. In TPS, confirm a visible transparent Mango. Distant enemies should stop acquiring attacks; close enemies (~3.5 m) can still fight. Confirm it is not invulnerability and opacity/normal detection return after 30 seconds.
9. Collect tequila at **(10,0,-72)**. Empty Molcajete/Cuete must still fire without spending reserves. Mango must lose no HP, fire faster, and have slight playable camera sway. Confirm the full renamed state and countdown. After 30 seconds, an empty weapon must be empty again, damage must apply, and sway must settle.
10. Combine powers, pause via **Esc/Tab/shop**, resume, and verify countdowns freeze during pause. Lose a life with powers active: effects must clear on respawn. Confirm temporary tequila immunity does not remove ordinary respawn protection.
11. Take damage and collect a botiquín: check HP cap, red healing crosses and pickup notice. At full HP, the kit should remain available. Hit each enemy several times quickly: red flash must retrigger and then clear, preserving the normal model and death reaction.
12. Compare Chancla base/PRO at medium distance; confirm longer useful flight, returning hit and recovery. Compare upgraded Molcajete and Komodo blast damage, size and cadence. Check ammunition after switching weapons and after power expiration.
13. Follow hot-zone transitions at **8:30, 7:00, 5:30, 4:00, 2:30 and 1:00** remaining. Check red ring/beam visibility at range, ceiling reach, objective HUD, bonuses and final-wave behavior. No Amor meter, pickups or F activation should appear.
14. Play one complete round to victory and a separate life-loss/defeat/restart sequence. In **Debugger → Monitors**, inspect FPS, process/physics time and object growth during crowded combat. Test camera comfort and UI at your actual resolution.

## Reproduce the automated checks

Run from the project directory, substituting your Godot executable path:

```powershell
$godot = 'D:\heezl\Descargas\Godot_v4.7.2-stable_mono_win64\Godot_v4.7.2-stable_mono_win64_console.exe'
& $godot --path . --rendering-method gl_compatibility --script scripts/test/professional_polish_audit.gd
& $godot --path . --rendering-method gl_compatibility --script scripts/test/production_combat_audit.gd
& $godot --path . --rendering-method gl_compatibility --script scripts/test/production_structure_audit.gd
& $godot --path . --rendering-method gl_compatibility --script scripts/test/environment_polish_audit.gd
& $godot --path . --rendering-method gl_compatibility --script scripts/test/beta_0_1_smoke.gd
& $godot --path . --rendering-method gl_compatibility --script scripts/test/beta_gameplay_audit.gd
& $godot --path . --rendering-method gl_compatibility --script scripts/test/professional_polish_review.gd
& $godot --path . --rendering-method gl_compatibility --script scripts/test/environment_polish_review.gd
& $godot --path . --rendering-method gl_compatibility --script scripts/test/production_horde_review.gd
git diff --check
```

See `reviews/professional_polish/files_changed.txt` for this pass's file inventory, separate from pre-existing unrelated working-tree changes. Logs are archived beside the curated screenshots.
