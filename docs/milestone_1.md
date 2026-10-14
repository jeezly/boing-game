# Milestone 1: playable prototype

Open project.godot in Godot 4.7. Press F5, or open scenes/main/main.tscn and press F6.

Controls: WASD move, Space jump, Shift sprint, mouse look, V switch first/third person, left mouse hold to fire debug_blaster, Escape release mouse, left click recapture.

The 18 by 20 meter graybox has an open front entrance and rear bodega doorway. All solid blocks have matching box collisions. The outside apron has boundary walls. Mango uses a capsule collider; its visual subtree can be replaced independently.

The camera shares yaw and pitch between both views. First person hides the placeholder. Third person uses a sphere-shaped SpringArm3D sweep against world geometry. The weapon queries from the active camera center, excludes the player, hits the first solid object, and calls take_damage when available. It deals 25 damage at four shots per second with 100 meter range and unlimited ammunition. The target resets two seconds after death.

## Manual validation in Godot
- Confirm no parse or missing resource errors on import and F5/F6.
- Walk into floor, walls, shelves, counter, refrigerators and crates; inspect collisions.
- Walk through both doorways, around shelves and into the bodega.
- Check acceleration, stopping, diagonal movement, jumping and sprinting.
- Toggle V while moving and aiming; verify matching orientation, immediate HUD updates and hidden first-person body.
- Back third-person camera against walls, shelves and doorway lintels; inspect spring-arm clipping at pitch limits.
- Escape releases the pointer; left click recaptures it.
- Hit the dummy four times: 75, 50, 25, 0 HP; verify it disappears and returns after about two seconds.
- Fire at a wall or shelf between camera and target and verify it blocks damage.

Static checks cannot prove engine parsing, physics behavior, camera collision feel or HUD appearance. No Godot executable was available on PATH; runtime validation must be performed in the editor. Third-person hits originate at the camera for crosshair alignment, with no muzzle simulation. A held capture click can fire once captured.
