# Milestone 3: La Abarrotera + Pepsin encounters

## Visual authority and preserved foundation

All three local reference images were viewed before editing: Mango, La Abarrotera, and Pepsin. Mango's geometry, procedural presentation, slingshot model, camera switching, movement tuning, and HUD bindings remain intact. No external assets, downloads, addons, dependencies, Blender models, other enemy types, or boss were used. `project.godot` retains Godot 4.7, GL Compatibility, Jolt Physics, and the same main scene path.

## Environment

`la_abarrotera.tscn` replaces the graybox instance in Main. Its script constructs an approximately 34 x 68 metre footprint, including the approach, shopping floor, bodega and rear patio. In the running Remote tree, geometry is grouped under `architecture`, `shopping_floor`, `bodega_and_patio`, and `lighting_and_dressing`.

The storefront has a cream facade, painted red base, window mullions, red awning, neighborhood signage, bollards, sidewalk board, and agave pots. Inside are two checkouts with registers and belts, four stocked double-sided aisles, wide central and perimeter routes, a cool refrigerator bank, produce displays, water jugs and grain sacks. Pallet stacks create partial cover. The industrial bodega has concrete floor coloring, stock stacks and two broad entry shutters. A back doorway leads to the loading canopy, yard markings, delivery truck and rear exit.

Color blocking, shelf price rails, fictional signage, papel picado, overhead signs, beams, lamp housings and cool refrigerator lights supply visual identity. Products and checker floor tiles use MultiMesh batches; environment materials are cached. The floor uses one continuous collider so decorative tile seams cannot snag players. Small display details deliberately have no separate collision; fixtures use simple coherent bounding boxes. The main store remains open above its overhead beams rather than using a fully enclosed ceiling, to preserve camera readability and inexpensive daylight lighting.

| Zone | Approximate Z range | Gameplay |
| --- | --- | --- |
| Exterior approach | 12 to 22 | Start at (0, 0.05, 18), walk through the entrance |
| Cajas / first shopping area | -4 to 12 | Open first fight, perimeter pallet cover |
| Aisles / refrigerators / produce | -24 to -4 | Central lane, shelf flank routes, second fight |
| Bodega | -36 to -24 | Two entry routes, stacks and supply pickup |
| Patio | -46 to -36 | Canopy, truck cover, final fight and exit |

## Encounter flow

Only one encounter is active at a time. Position thresholds are evaluated in Main's authored coordinates, avoiding fragile Area3D trigger wiring and premature starts. The manager shows objectives, remaining enemies and short notices.

1. Enter past Z=7: two Pepsins near the cajas. Defeat both to unlock the second encounter trigger.
2. Advance past Z=-8: three Pepsins in the deeper aisles. Defeat all three to open both bodega shutters and rebuild navigation.
3. Enter past Z=-26: four Pepsins distributed across the bodega and patio. Defeat all four, then walk past Z=-43 in the rear yard to complete the scenario.

Retreat and flank routes remain available; there is no endless wave spawner. Three single-use health supplies restore 30 HP, clamped to 100. They remain available if touched at full health. Dead players cannot heal. Health loss emits the existing HUD signal. Player death or scenario completion pauses gameplay, releases the mouse and displays a restart button. R or the button reloads the entire scenario, restoring HP, pickups, encounters and closed shutters. This is a full restart, not a checkpoint/save system. Escape retains its existing mouse-release behavior; no new pause menu was introduced.

The old graybox and target dummy are retained in `scenes/test/weapon_test.tscn`, runnable with F6.

## Pepsin hierarchy and presentation

```text
pepsin (CharacterBody3D, pepsin.gd)
  collision_shape (capsule)
  visual (pepsin_visual.gd)
    blue_jacket / pale_face / eyes / eyebrows / grin
    pointed_ears / raised_goggles
    jester_lobes / drooping_cap_tips / silver_bells
    articulated_legs / striped_sport_boots
    articulated_sleeves / white_gloves
    weapon_mount
      soda_blaster_visual (separate PackedScene)
        bottle_chamber / collars / red_nozzle / grip
        projectile_socket (Marker3D)
  attack_tell (pulsing blue cue above the head)
```

Pepsin follows the reference's blue-red-white palette, compact duende proportions, pale expressive face, pointed ears, twin drooping jester cap, goggles and sporty footwear. Bubble details are fictional decorations, not real brand logos. Walking uses procedural leg swing and bob. Hits flash the model for 0.13 seconds, interrupt attacks for a short stagger, and print remaining HP. Death disables collision immediately, emits the encounter signal once, then tips/shrinks the model before freeing it.

## AI and navigation

The encounter manager activates Pepsin with explicit player/store references. Before activation it waits. Active enemies approach Mango, check range and line of sight, stop to telegraph for 0.48 seconds, fire at the player's position captured at the start of the cue, then reposition. Moving during the cue allows dodging. Each shot alternates the preferred strafe side; spawn-index cooldown offsets reduce synchronized attacks. Losing line of sight causes approach/pathfinding rather than firing through shelves. Damage interrupts the windup; death stops all AI.

Navigation uses native [AStarGrid2D](https://docs.godotengine.org/en/stable/classes/class_astargrid2d.html), the requested equivalent navigation approach for this flat level, rather than NavigationRegion3D/NavigationAgent3D. The one-metre grid uses orthogonal paths and footprints expanded by 0.62 metres. It is constructed from the same major solids/fixture dimensions as the environment, and rebuilt when shutters open. Enemies request paths every 0.45 seconds and physically move with CharacterBody3D.move_and_slide. This avoids editor baking, diagonal corner cutting and walking through solid props. It is not full crowd avoidance or multilevel navigation; physical body collision handles other actors.

Baseline tuning: 75 HP, 3.2 m/s movement, 12 metre attack range, 10 damage, 10 m/s bubble speed, 1.8 second cooldown after the 0.48 second windup. Three normal mango hits defeat one Pepsin. Difficulty still needs playtesting.

## Weapon/projectile architecture

The separate soda bottle launcher scene constructs a blue chamber, silver collars, red perforated nozzle, wrapped grip and bubble decorations. Enemy AI owns firing cadence and windup; the weapon visual owns its muzzle and small recoil. Bubble shots originate at the bottle's projectile_socket and travel toward the captured target position. A short body-to-muzzle world ray prevents barrels shooting through nearby shelves.

Both weapons share `projectile.gd`: a visible CharacterBody3D projectile, swept move_and_collide, shooter exception, take_damage call, destruction on contact and lifetime expiry. An optional impact_scene leaves mango pellets unchanged while soda bubbles create a brief native-mesh fizz burst. Soda bubbles have a glossy blue body, white glint and small attached trail bubbles, with five-second lifetime.

Collision layers: world=1, player=2, Pepsin=4. Mango pellets and crosshair aim queries use mask 5 (world + Pepsin). Soda bubbles use mask 3 (world + player), so they cannot damage their shooter or other Pepsins. Player mask 5 and enemy mask 7 make actor movement physically collide. The existing TPS slingshot socket/camera-target aiming remains preserved. Mango's 25 damage, 24 m/s projectile speed and 3 shots/second fire rate are unchanged.

## Static validation performed

The shell reported helper_unknown_error; work continued through file tools and scene/script editing as requested. Godot was previously unavailable on PATH and no engine validation was performed for this milestone. Static checks are not a claim of runtime success.

- Re-read every new or modified script and scene. Checked preload/resource paths, scene ExtResource/SubResource IDs, node references, signal bindings, HUD integration and collision mask relationships.
- Scanned 38 GDScript/scene files: no missing referenced resources, undefined resource IDs or trailing whitespace found.
- Expanded the Main, weapon test, enemy, pickup and weapon scene hierarchies and checked 47 static NodePath references, including the HUD camera and encounter-manager sibling bindings: no missing nodes found. Runtime-generated weapon sockets were also reviewed in their source scenes/scripts.
- Independently reconstructed the 48 major obstacle footprints and flood-filled the authored planar layout with the configured clearance. All nine encounter spawn cells are unblocked and reachable in their intended gate state. The closed map has 1,102 entrance-connected cells; opening shutters yields 1,557. Both bodega passages and the rear exit connect after opening; the bodega is disconnected from the entrance beforehand. This is a numerical layout audit, not a Godot physics simulation.
- Verified Main still instances the existing Player and HUD, the active Resortera de Mango scene and both camera modes remain, and the dummy is available in the dedicated test scene.
- Reviewed death/restart pause inheritance: enemies, projectiles and pickups are Main children, not children of the always-processing result UI manager.

## Required Godot manual tests

1. Open project.godot in Godot 4.7 and run Main with F5. Confirm zero script/resource errors, GL Compatibility and Jolt. Environment and character detail meshes are built at runtime; inspect the Remote scene tree.
2. Inspect the facade and all five main geographic zones. Test every aisle, both perimeter routes, cover stacks and rear doorway in FPS and TPS. Check camera obstruction, visibility, collision and jump clearance.
3. Confirm WASD, sprint, jump, look, V, Escape/re-capture, the existing Mango/slingshot pose and HUD remain working. Fire in both modes at cover and enemies. Check origin from the visible slingshot and crosshair accuracy.
4. Verify encounters start in sequence with counts 2, 3 and 4. Check remaining-count updates, no repeated starts and no fourth encounter. Both shutters must block progression until the second clear, then stop colliding.
5. Watch Pepsins route around shelves, pallets and walls. Lead them between adjacent aisles and through both bodega accesses. Verify they close range when obstructed, strafe in open space, telegraph, shoot, recover and react to hits. Watch for crowd jams or grid jitter.
6. Land three 25-damage mango hits on one Pepsin: Output should show 50, 25, 0 HP, brief flashes and a clear death. Check it no longer blocks movement or counts as alive during the death animation.
7. Take soda hits: each subtracts 10 HP and updates the existing bar/numeric display. Dodge during the telegraph. Use shelf cover, check fizz impacts, expiry, and no friendly/self damage to Pepsins.
8. Collect a supply below full health: restores 30 HP up to 100 and disappears once. At full HP it remains. Check all three supplies are reachable.
9. Let Mango reach zero HP: game freezes and the mouse is released. Click restart or press R; verify 100 HP, fresh encounters/pickups, closed shutters, captured mouse and working cameras/firing.
10. Clear all nine enemies and reach the marked rear exit: completion panel appears. Restart from completion and test the full flow again, ideally once per camera mode. Review Compatibility-renderer frame rate and difficulty.
11. Open weapon_test.tscn and use F6 to confirm the original dummy still loses HP and respawns after two seconds.

## Approximation and limits

This is a native stylized playable prototype, not a final textured/sculpted asset pass. Pepsin uses articulated primitives rather than a skeleton. Refrigerator doors are stylized opaque display panels. The delivery truck, sacks, plant details and package products are simplified. Most decoration is non-colliding and fixtures have bounding-box collision. Store construction is in Main-local coordinates; moving/rotating the entire store would require transforming navigation coordinates. AI does not jump, climb shelves, use full crowd avoidance or solve multilevel routes. There is no audio pass, checkpoint persistence, enemy loot system or new pause menu. Runtime visuals, collision feel, frame rate and encounter balance remain unverified until manual tests pass.

## Exact files created

- scenes/environment/la_abarrotera.tscn
- scenes/environment/store_fixture.tscn
- scenes/enemies/pepsin.tscn
- scenes/weapons/soda_blaster_visual.tscn
- scenes/projectiles/soda_bubble.tscn
- scenes/projectiles/soda_impact.tscn
- scenes/game/encounter_manager.tscn
- scenes/game/health_pickup.tscn
- scenes/test/weapon_test.tscn
- scripts/environment/la_abarrotera.gd
- scripts/environment/store_builder.gd
- scripts/environment/store_fixture.gd
- scripts/environment/store_navigation.gd
- scripts/enemies/pepsin.gd
- scripts/enemies/pepsin_visual.gd
- scripts/weapons/soda_blaster_visual.gd
- scripts/projectiles/soda_impact.gd
- scripts/game/encounter_manager.gd
- scripts/game/health_pickup.gd
- docs/milestone_3.md

## Exact files modified

- scenes/main/main.tscn
- scenes/player/player.tscn
- scenes/projectiles/mango_projectile.tscn
- scripts/player/player_controller.gd
- scripts/weapons/projectile_weapon.gd
- scripts/projectiles/projectile.gd

Supplied reference images, previous milestone documents, HUD scenes/scripts, camera controller, Mango visual scripts/scenes, slingshot visual scripts/scenes, original graybox and target dummy were not modified.
