# Store environment polish pass

The Mega Abarrotera uses cream plaster, teal metalwork, terracotta trim, honey-colored timber and restrained department colors. This pass keeps the existing store footprint and gameplay collision layout, then gives those spaces a consistent architectural finish.

## What changed

- Complete roof treatment for the loading patio, matching upper rear enclosure, repeated steel trusses, purlins, suspended diffusers, cornices, wall piers and colored perimeter bands.
- Framed central store identity, smaller welcome signage, glazed storefront sections, tiled plinths and finished entrance jambs. The original entrance opening and bollard collision remain intact.
- Numbered aisle markers, category colors, endcap crowns, checkout soffit, checkout numbers and interior-facing exit signage. Shelf positions and combat lanes remain intact.
- Market canopies above the existing fruit fixtures, individually editable captions, painted rear panel, tiled frieze and a granel landmark. Produce displays remain in their original positions.
- Cooler pelmet and cold-drinks sign, loading shutters with ribs and protective striping, service markings and delivery-truck trim.
- Pink and cream laundry-soap stacks and wrapped-sweet displays sit on existing huacales. Existing crates, sacks, returnables, papel picado and pinatas retain the neighborhood-store identity.
- Lighter ceramic floor, subtler grout, department tinting and more neutral interior lighting.
- Superseded floating signs, blank signboards and opaque fake paper-cutout blocks were removed. The actual papel picado cutout shader remains.

## Editing map and complete changed-file inventory

Modified production files:

- `scenes/environment/mega_abarrotera/mega_abarrotera.tscn`: assembly now about 347 lines instead of about 5,500; gameplay markers, shop, pickups and zone roots stay accessible.
- `scenes/game/main.tscn`: ambient lighting adjustment only in this pass.
- `resources/environment/store_floor.gdshader`: lighter ceramic, subtler grout and department tinting.
- `scripts/enemies/polar/polar_visual.gd`: overhead anticipation, downward arm arc and forward body weight.

New authored zone scenes under `scenes/environment/mega_abarrotera/zones/`:

- `store_shell.tscn`
- `storefront.tscn`
- `checkouts.tscn`
- `shopping_aisles.tscn`
- `cold_department.tscn`
- `produce_and_grain.tscn`
- `stockroom.tscn`
- `loading_patio.tscn`
- `interior_lighting.tscn`

These hold the existing saved geometry and fixtures. Root names, transforms, combat-zone scripts and entrance paths are preserved. Open a zone scene directly to edit its contents.

New authored scenes under `scenes/environment/mega_abarrotera/polish/`:

- `store_finish.tscn`: finish assembly.
- `architecture_finish.tscn`: roof completion, trims and department portals.
- `facade_finish.tscn`: storefront framing and identity.
- `retail_finish.tscn`: checkout, aisle and cooler finish.
- `market_finish.tscn`: fruit/granel composition.
- `service_finish.tscn`: loading and stockroom finish.
- `merchandise_finish.tscn`: fixture-top merchandise and delivery-vehicle details.
- `ceiling_bay.tscn`: reusable steel roof bay with suspended diffuser.
- `storefront_window.tscn`: reusable framed glazing.
- `produce_canopy.tscn`: reusable striped market canopy.
- `soap_stack.tscn`: laundry-soap display.
- `dulces_display.tscn`: sweets tray.
- `truck_finish.tscn`: delivery-body details.

New scripts:

- `scripts/environment/mega_abarrotera/static_fixture_batch.gd`: reuses the existing visual batcher for immutable mesh pieces at runtime. Meshes remain separate and editable in the editor.
- `scripts/environment/mega_abarrotera/market_canopy.gd`: exposes each canopy caption in the inspector and batches its static meshes at runtime.
- `scripts/test/environment_polish_audit.gd`: routes, zone contracts, collision boundaries and overhead-pose geometry.
- `scripts/test/environment_polish_review.gd`: 14 rendered captures and a static rendered performance sample.
- Godot-generated `.gd.uid` companions for these new scripts.

## Gameplay boundaries

The finish adds zero CollisionObject3D/CollisionShape3D nodes. Existing static bodies, navigation-obstacle membership, ramps, shop access, objective markers, spawn markers and respawn markers remain in the saved zone scenes. Mango, weapons, HUD and survival logic were not changed in this pass. GL Compatibility and Jolt Physics remain selected. No addons or new game systems were added.

## Polar

Both paws rise above the head during the existing windup, then swing down and forward during the existing strike window. The torso leans back for anticipation and forward for impact. Exponential pose interpolation is independent of frame rate. Attack damage, reach, combo sequence, windup duration, hit checks and cooldowns remain unchanged.

## Validation

Godot 4.7.2 imported the project without errors.

- Production structure audit: **583 checks, 0 failures**.
- Production combat audit: **103 checks, 0 failures**.
- Environment polish audit: **68 checks, 0 failures**. Includes connected routes from the entrance to all enemy-spawn, respawn and objective markers, seven indexed zones, preserved entrance callback and shop/truck collision contracts, zero finish colliders, and paw positions above the head followed by downward/forward positions.
- Fourteen rendered views inspected across storefront, checkouts, aisles, coolers, produce, stockroom, loading patio, ceiling, merchandise and Polar poses. Files: `.godot/environment_polish_review/`.
- Existing rendered horde review: **58.9 FPS mean**, **22.03 ms p95**, with peaks of **22 enemies, 8 projectiles and 5 effects**, over 20 seconds on the available GTX 1650 Max-Q machine. This is a short local sample, not a full-match or cross-hardware guarantee.
- Final uncapped static checkout sample: **10.97 ms/frame**. Immutable finish batching reduced an earlier same-view sample from 6065 to about 5292 draw calls; the scene still contains substantial existing character/prop rendering cost.
- `git diff --check`: no whitespace errors.

Re-run with the Godot console executable and `--path . --script scripts/test/environment_polish_audit.gd` (use `--headless` for audits). Run `environment_polish_review.gd` without `--headless` for rendered captures.

## Manual Godot walkthrough

1. Run `scenes/game/main.tscn`, enter the store and confirm that survival starts normally. Check both first-person and third-person views.
2. Cross all aisle breaks, circle the produce fixtures, visit the cold section, use both stockroom ramps and move around the loading truck.
3. Open and buy from Don Plomazo, collect pickups and follow objectives through all departments.
4. Fight Polar at close range, including the three-hit combo. Look for raised paws before a downward strike; confirm the familiar damage and recovery rhythm.
5. Play a full survival match and check late-wave frame pacing on the intended target hardware.
6. Open the individual zone and polish scenes in the editor. Verify canopy caption overrides and fixture editability.

## Later visual opportunities

Custom product-label textures, more varied fruit silhouettes, a dedicated stylized material/texture pass and broader renderer optimization could improve close-up quality further. They are not needed to use the finished architectural and department-layout polish delivered here.
