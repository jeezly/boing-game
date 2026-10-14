# Milestone 3a — Mango polish and project cleanup

Approved visual authority: `docs/references/mango/mango_sheet_final.jpg` (inspected before changes).

## Scope and outcome

Mango presentation and project organization only. Existing movement, health, camera switching, firing rate, damage, projectile launch, wall obstruction checks, HUD, and encounters retain their gameplay logic. Pepsin and La Abarrotera files received relocation/dependency updates only. GL Compatibility and Jolt Physics remain selected. No addons or new gameplay content.

## Organization and hierarchy

```text
scenes/
  characters/mango/     player, Mango visual, backpack
  enemies/pepsin/       existing enemy
  environment/la_abarrotera/  existing store and fixture
  weapons/             existing weapon logic/visual scenes
  projectiles/         existing projectile scenes
  ui/                  HUD
  game/                main, encounter manager, health pickup
  test/                weapon test, dummy, old store graybox
scripts/
  characters/mango/    controller, camera, appearance, visual posing, backpack
  enemies/pepsin/       existing enemy scripts
  environment/la_abarrotera/  existing store scripts
  components/          shared visual geometry builder
  weapons/, projectiles/, ui/, game/, test/
```

Main already contained sensible instances; retain its six high-level nodes: la_abarrotera, Player, encounter_manager, directional light, WorldEnvironment, HUD. Startup now points to `res://scenes/game/main.tscn`.

Mango visual exposes body, face, helmet, backpack instance, limbs with four named pivot nodes, and weapon_socket/slingshot instance. Body/face/helmet construction is separate from posing. Backpack is its own scene. Slingshot exposes frame, elastic, pouch, FPS hands, muzzle, and projectile_socket. TPS reuses the visible socket instance rather than creating a second runtime prop; FPS instantiates the same prop with its dedicated hands and keeps Mango hidden.

Tool scripts preview Mango, backpack, and slingshot in the editor. Generated meshes remain transient/unowned: use the named scene groups to place parts and scripts to edit shapes. They are not individual saved editable meshes. Runtime/debug inspection can expand generated detail. The store remains its existing procedural scene; its art and layout were not rebuilt.

## Visual work

- Single smooth tapered/asymmetric fruit mesh replaces intersecting body and face ovals; local-space shader supplies a warm yellow-to-orange gradient.
- Open curved leather helmet follows the crown without a filled cut plane; adds seam stitching, flap edging, chin straps and buckles.
- Layered leather/metal goggles with opaque reflective lenses, curved eyebrows, cream eyes, orange nose, surface-following smile and lip/chin shapes.
- Rounded shoulder/elbow/ankle joins; glove cuffs, thumbs and fingers follow hand poses.
- Ochre hiking boots have ankle uppers, rounded toes, padded collars, tongues, cross laces/eyelets, contrasting welts, soles and tread.
- Backpack now has a rounded rectangular volume attached into the back, flap edging/stitches, closure strap and buckle, side pockets, carry loop and leaf badge. Harness wraps from pack over shoulders to torso and back.
- Slingshot handle overlaps the central joint and smooth swept wooden forks. Tip bindings share fork anchors; leather emblem and rivets sit against wood. Pouch cradle and attachment tabs move together.
- Both FPS and TPS bands recompute their transforms between fixed fork anchors and moving pouch attachment points, including recoil. This fixes the FPS disconnected-band bug.
- TPS holding hand stays on the grip; drawing hand follows the pouch during the aiming pose. FPS shows only the weapon and dedicated holding glove/wrist.

## Exact file manifest

Paths below are relative to the project root. Sidecars listed in moves retain their original UIDs.

### Created

- `scripts/characters/mango/mango_appearance.gd`
- `scripts/characters/mango/mango_backpack.gd`
- `scenes/characters/mango/mango_backpack.tscn`
- `docs/milestone_3a_mango_polish.md`

### Moved/renamed

| Original | Destination |
| --- | --- |
| scripts/player/player_controller.gd | scripts/characters/mango/player_controller.gd |
| scripts/player/player_controller.gd.uid | scripts/characters/mango/player_controller.gd.uid |
| scripts/player/camera_controller.gd | scripts/characters/mango/camera_controller.gd |
| scripts/player/camera_controller.gd.uid | scripts/characters/mango/camera_controller.gd.uid |
| scripts/player/mango_visual.gd | scripts/characters/mango/mango_visual.gd |
| scripts/player/mango_visual.gd.uid | scripts/characters/mango/mango_visual.gd.uid |
| scripts/player/mango_mesh_builder.gd | scripts/components/visual_mesh_builder.gd (rewritten shared helper) |
| scripts/player/mango_mesh_builder.gd.uid | scripts/components/visual_mesh_builder.gd.uid |
| scenes/player/player.tscn | scenes/characters/mango/player.tscn |
| scenes/player/mango_visual.tscn | scenes/characters/mango/mango_visual.tscn |
| scripts/enemies/pepsin.gd | scripts/enemies/pepsin/pepsin.gd |
| scripts/enemies/pepsin.gd.uid | scripts/enemies/pepsin/pepsin.gd.uid |
| scripts/enemies/pepsin_visual.gd | scripts/enemies/pepsin/pepsin_visual.gd |
| scripts/enemies/pepsin_visual.gd.uid | scripts/enemies/pepsin/pepsin_visual.gd.uid |
| scenes/enemies/pepsin.tscn | scenes/enemies/pepsin/pepsin.tscn |
| scripts/environment/la_abarrotera.gd | scripts/environment/la_abarrotera/la_abarrotera.gd |
| scripts/environment/la_abarrotera.gd.uid | scripts/environment/la_abarrotera/la_abarrotera.gd.uid |
| scripts/environment/store_builder.gd | scripts/environment/la_abarrotera/store_builder.gd |
| scripts/environment/store_builder.gd.uid | scripts/environment/la_abarrotera/store_builder.gd.uid |
| scripts/environment/store_fixture.gd | scripts/environment/la_abarrotera/store_fixture.gd |
| scripts/environment/store_fixture.gd.uid | scripts/environment/la_abarrotera/store_fixture.gd.uid |
| scripts/environment/store_navigation.gd | scripts/environment/la_abarrotera/store_navigation.gd |
| scripts/environment/store_navigation.gd.uid | scripts/environment/la_abarrotera/store_navigation.gd.uid |
| scenes/environment/la_abarrotera.tscn | scenes/environment/la_abarrotera/la_abarrotera.tscn |
| scenes/environment/store_fixture.tscn | scenes/environment/la_abarrotera/store_fixture.tscn |
| scenes/environment/la_tiendita_graybox.tscn | scenes/test/la_tiendita_graybox.tscn |
| scenes/main/main.tscn | scenes/game/main.tscn |
| scenes/main/hud.tscn | scenes/ui/hud.tscn |

### Modified (final paths; excludes files only relocated)

Presentation or integration:
- `scripts/components/visual_mesh_builder.gd`
- `scripts/characters/mango/mango_visual.gd`
- `scenes/characters/mango/mango_visual.tscn`
- `scripts/weapons/slingshot_visual.gd`
- `scenes/weapons/mango_slingshot_visual.tscn`
- `scripts/weapons/projectile_weapon.gd`

Resource/startup path updates:
- `project.godot`
- `scripts/characters/mango/player_controller.gd`
- `scenes/characters/mango/player.tscn`
- `scripts/enemies/pepsin/pepsin.gd`
- `scripts/enemies/pepsin/pepsin_visual.gd`
- `scenes/enemies/pepsin/pepsin.tscn`
- `scripts/environment/la_abarrotera/la_abarrotera.gd`
- `scripts/environment/la_abarrotera/store_fixture.gd`
- `scenes/environment/la_abarrotera/la_abarrotera.tscn`
- `scenes/environment/la_abarrotera/store_fixture.tscn`
- `scripts/game/encounter_manager.gd`
- `scripts/game/health_pickup.gd`
- `scenes/game/main.tscn`
- `scripts/projectiles/soda_impact.gd`
- `scripts/ui/hud.gd`
- `scripts/weapons/hitscan_weapon.gd`
- `scripts/weapons/soda_blaster_visual.gd`
- `scenes/test/weapon_test.tscn`

Old Mango-specific primitive helper is replaced by the shared component (same UID). Graybox remains available under test scenes. Existing milestone documents remain historical.

## Validation and limits

Godot is not available on PATH. Static validation passed:
- 61 resource paths exist.
- All scene ExtResource/SubResource IDs and declared parent paths resolve.
- Expanded main and weapon-test scene graphs contain 46 and 116 nodes respectively.
- 81 literal script/scene NodePaths resolve within those graphs.
- 22 existing script UID sidecars are unique, including the relocated mesh helper.
- Basic source delimiter checks pass; no old resource folder paths remain.
- Main startup, GL Compatibility, and Jolt settings are correct.

These checks do not establish Godot parser, shader compilation, scene-load success, runtime correctness or visual quality. No runtime or rendered screenshot validation was possible. Godot will generate UID sidecars for the newly created scripts when imported.

Native modeling is still an approximation of the reference: no sculpted leather/wood textures, UV atlas, normal maps, skeletal skinning, facial animation or anatomical fingers. The smile is a fixed expression; goggle lenses are opaque for readability. Some accessory seams use joined primitives, straps are rounded cords rather than stitched flat leather ribbons, and arm poses are procedural segments rather than skinned joints. Final fidelity and camera-distance readability require visual review. Primitive defaults for shared non-Mango users remain unchanged.

## Manual Godot 4.7 checks

1. Open/import the project. Check the debugger for GDScript or shader errors, and confirm the main scene is scenes/game/main.tscn.
2. Open Mango visual, backpack, slingshot visual and player scenes; inspect their editor previews and instanced hierarchies.
3. Compare Mango's front, side, back and three-quarter views against the approved sheet. Review body/face/helmet joins, backpack harness and boot silhouette.
4. Run main (F6 on the main scene or F5). Verify movement, sprint, jumping, collision and mouse capture/release.
5. Press V repeatedly while moving and firing. FPS must hide the body and TPS must hide the FPS glove.
6. Aim upward/downward and turn while firing. Inspect grip/pouch contact, band endpoints and torso clearance in TPS; inspect recoil and near-camera clipping in FPS.
7. Verify crosshair aim, projectile hits, damage, fire cadence and wall-obstruction behavior in both modes, especially at close range.
8. Run scenes/test/weapon_test.tscn and shoot the target dummy from both camera modes.
9. Confirm HUD mode/health/ammo display, incoming damage, health pickups, death/restart, all three existing encounters, opening shutters and final exit.
10. Inspect readability at normal TPS distance and against store backgrounds; check performance with encounters active.

Stop here. Pepsin polish, store polish, additional enemies/weapons, level growth and new gameplay systems are outside this milestone.

