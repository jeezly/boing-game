# Milestone 2A: Mango and Resortera de Mango

The local `docs/references/mango/mango_sheet_final.jpg` was inspected before implementation and is the visual authority. Blender and Godot were not found on PATH. Mango uses native Godot primitive meshes, separate articulated arms/legs, an orange/yellow fruit body, pilot helmet, raised goggles, eyebrows, eyes, nose, smile, yellow gloves, tan boots with cuffs/laces/soles, and a leather backpack with leaf badge. Geometry is assembled when the visual scene enters the tree; inspect it in the running game's Remote tree.

The CharacterBody3D controller and collision capsule remain. The full model is hidden in first person; a separate camera-mounted slingshot and glove remain visible. Third person shows Mango and a hand-mounted slingshot, with a slight shoulder camera offset. Procedural presentation supplies idle bob, speed-scaled leg swing, airborne legs, and a smoothed aiming pose while firing. This is an articulated approximation, not a skeletal rig or final textured asset.

`mango_slingshot.tscn` is the active weapon. Its reusable projectile weapon script exposes the visual/projectile scenes and fire tuning. Hold left mouse to fire, with a 3 shots/second cooldown, infinite ammo, 25 damage, and 24 m/s straight-moving pellets. The camera ray selects a crosshair aim point; it never deals damage. The active visual's muzzle spawns the projectile, with a wall obstruction check. Firing raises the arms and flexes the pouch/bands. There is no reload or charge system.

The reusable projectile uses `CharacterBody3D.move_and_collide` for swept spherical collision against layer 1. On impact it calls `take_damage` when supported, then frees itself. It expires after four seconds. The shooter is excluded explicitly and the player's layer 2 is outside the current projectile mask. Existing target dummy damage and two-second respawn remain untouched.

Player health starts at 100/100; `take_damage` clamps health and emits `health_changed`. HUD listens to that signal and displays both a bar and numeric health, weapon name, infinite ammo, crosshair, and camera mode. Existing Escape mouse release and click recapture remain.

## Validation

Static review only: re-read all new/modified scripts and scenes, checked resource references and retained renderer/physics settings. Godot was not callable from PATH, so engine parsing, scene loading, visual quality, and collision behavior require manual confirmation.

1. Open `project.godot` in Godot 4.7. Confirm GL Compatibility, Jolt Physics, and no script/import errors. Open the player scene and run `main.tscn` with F6 or the project with F5.
2. Confirm HUD: 100/100 HP, health bar, Resortera de Mango, infinite ammo, crosshair, FIRST PERSON.
3. Test WASD, Shift sprint, Space jump, mouse look, Escape release, and click recapture. Press V repeatedly; confirm THIRD PERSON and the full fruit character, and a clear first-person view with glove/slingshot only.
4. Observe idle, walk/run, jump/fall, and held-fire poses. Look up/down while firing in both modes and check third-person hand/weapon alignment.
5. Aim at the starting dummy: expect visible travel and Output HP messages 75, 50, 25, 0. After two seconds it should reappear with 100 HP and accept damage again. Repeat in TPS.
6. Fire at floors/walls and near wall edges. Pellets should stop on the first surface, not pass through the wall from a blocked muzzle. Missed shots should disappear after four seconds. Player HP should remain unchanged by their own pellets.
7. To exercise HUD health without adding gameplay, temporarily call `$Player.take_damage(25.0)` from a one-shot test script on Main after readiness; confirm 75/100 and bar reduction, then remove the test invocation.

Limitations: no runtime validation available; primitive materials and facial/hand poses need visual review. No skeletal animation, IK, charged draw, player death/respawn, or incoming damage source is added. No enemies, waves, level redesign, dependencies, downloads, or addons.

## Files created

- `scenes/player/mango_visual.tscn`
- `scenes/weapons/mango_slingshot.tscn`
- `scenes/weapons/mango_slingshot_visual.tscn`
- `scenes/projectiles/mango_projectile.tscn`
- `scripts/player/mango_mesh_builder.gd`
- `scripts/player/mango_visual.gd`
- `scripts/weapons/projectile_weapon.gd`
- `scripts/weapons/slingshot_visual.gd`
- `scripts/projectiles/projectile.gd`
- `docs/milestone_2a.md`

## Files modified

- `scenes/player/player.tscn`
- `scenes/main/hud.tscn`
- `scripts/player/player_controller.gd`
- `scripts/player/camera_controller.gd`
- `scripts/ui/hud.gd`

The prior hitscan script remains available but is no longer instantiated by the player. The reference image was supplied by the user and was not created or modified during this milestone.
