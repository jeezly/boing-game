# Milestone 3b — Mango final presentation, Pepsin polish and combat reactions

## Scope

Inspected the approved Mango and Pepsin sheets before editing. Presentation for the two existing characters and their existing weapons only. No new weapon/enemy type, power-up, encounter, level layout or navigation system. No files moved. GL Compatibility and Jolt Physics remain selected.

## Mango

The backpack shell is wider and slightly inset into the back. Its attached flap/pockets/badge follow the new shell placement. Flat segmented leather straps replace rounded cords and wrap over the shoulders, across the torso and back into the pack. The existing scene remains independent.

Boot soles and welts now have oval outlines with flat undersides. Rounded ankle uppers and tongues replace square forms. Torus collars create padded boot openings; the reference's ochre palette, laces, toe volume and tread remain.

Mango now uses a child presentation pivot for hit/firing/death transforms. Camera yaw remains on the visual root, and collision/movement stay on Player. Idle breathing, movement/running bounce and stride, existing aim/draw poses, firing/recovery, a brief damage flash/flinch and a falling death pose are supported. The visual can finish its death pose after the existing result screen pauses gameplay. FPS receives a small weapon jolt and a brief screen-edge pulse; the actual camera and aim ray do not shake.

## Slingshot ammo and rhythm

A reusable mango-and-leaf scene is instanced in both the pouch and the live projectile. The pouch supports the fruit's lower portion, and the ammo stays attached as the elastic draws/recoils. A pulling glove is added to FPS presentation.

Both modes now spawn from the pouch's ammo-center marker rather than the FPS forward muzzle. The projectile inherits the loaded visual's orientation without inheriting squash/scale. The loaded representation hides only after a successful launch. Both camera presentations share the existing weapon's visual readiness timer, so mode switching cannot restore stale loaded ammo.

At the default three shots/second, the pouch stays empty for approximately 0.23 seconds and seats a replacement mango over the remaining approximately 0.10 seconds. This is visual readiness only: no ammo accounting or firing-balance changes. Both props advance together in the weapon's physics update; bands and hand contact use the current pouch pose.

The original wall obstruction checks remain. TPS blocked launches retain loaded ammo. FPS retains its existing wall-safe spawn fallback, so a shot near a wall can intentionally be relocated to the safe side of the obstruction rather than the pouch. The original attempted-shot cooldown remains unchanged.

## Pepsin and existing soda blaster

Pepsin now instances a dedicated visual scene with torso, face, cap/lobes, limb pivots and weapon mount. Construction is separated into an appearance helper; poses/reactions remain in the visual controller. The scene previews in the editor.

Reference-led additions:
- Broader pale face, integrated rounded cheeks, blush, larger readable eyes, curved sly eyebrows, button nose and smirk.
- Swept pointed ears with inset pink interiors.
- Continuous tapering red/blue drooping cap lobes, silver bells, white bubble markings and a fitted cap base.
- One blue wraparound visor with a raised nose bridge, silver rim, red seal, foam backing, reflections and attached strap.
- Puffy electric-blue jacket, navy waist, red collar/hem, white chest wave, zipper/teeth, drawstrings and bubble markings.
- Rounded sporty shoes with navy soles, red toes/collars, white stripes and side badges.
- Articulated upper/fore sleeves with rounded joins, red cuffs, white gloves/thumbs/fingers. Both hands follow dedicated blaster grip sockets.

The existing soda blaster has a cylindrical glossy blue chamber, bottle shoulder, silver collars/rails/rivets, rear canister, ribbed red nozzle with attached ports, bubble graphics, wrapped grip, trigger and guard. Only its chamber recoils, leaving grip contact stable. Windup produces a restrained chamber tremble; firing emits a brief small bubble cue at the nozzle while the actual damaging bubble launches from the same barrel assembly.

Pepsin states: idle breathing, locomotion stride/bounce/lean, cap/bell sway, aiming/attack anticipation, firing/recovery, hit flash/flinch and death collapse. Existing hit stun still cancels windup. Defeat is reported immediately, collisions disable as before, and the collapsed visual remains for 0.90 seconds before removal. Physical knockback was not added; recoil is visual only.

## Files created

- scripts/components/character_reactions.gd
- scripts/components/presentation_shapes.gd
- scripts/enemies/pepsin/pepsin_appearance.gd
- scripts/ui/combat_feedback.gd
- scenes/projectiles/mango_ammo_visual.tscn
- scenes/enemies/pepsin/pepsin_visual.tscn
- scenes/ui/combat_feedback.tscn
- docs/milestone_3b_character_combat_polish.md

## Files modified

- scripts/characters/mango/player_controller.gd
- scripts/characters/mango/mango_visual.gd
- scripts/characters/mango/mango_appearance.gd
- scripts/characters/mango/mango_backpack.gd
- scripts/enemies/pepsin/pepsin.gd
- scripts/enemies/pepsin/pepsin_visual.gd
- scripts/weapons/projectile_weapon.gd
- scripts/weapons/slingshot_visual.gd
- scripts/weapons/soda_blaster_visual.gd
- scenes/characters/mango/player.tscn
- scenes/characters/mango/mango_visual.tscn
- scenes/enemies/pepsin/pepsin.tscn
- scenes/weapons/mango_slingshot_visual.tscn
- scenes/weapons/soda_blaster_visual.tscn
- scenes/projectiles/mango_projectile.tscn

## Static validation

Godot is unavailable on PATH. No runtime, Godot parser, shader compilation or rendered visual verification was performed.

Static review passed:
- 74 resource paths exist.
- Scene resource IDs, declared parents and recursive instance graphs resolve.
- 139 literal NodePaths resolve across main, weapon test, Pepsin, slingshot and live mango projectile graphs.
- Dynamic grip/support/pouch/barrel socket paths resolve.
- Presentation methods and player damage signal/HUD health hooks exist.
- 22 existing script UIDs remain unique; new script UIDs will be created during Godot import.
- Basic delimiters and indentation checks pass.
- Startup remains scenes/game/main.tscn; renderer/physics settings remain unchanged.
- Ten gameplay functions match pre-edit copies: Mango movement/heal, Pepsin activation/movement/attack/line-of-sight, Mango aim selection/ammo text, and projectile launch/collision processing.

Death cleanup timing and visual projectile origin/orientation are the intentional integration changes. Damage amounts, fire cadence, AI ranges, health values, encounter bookkeeping, navigation, camera switching and projectile collision logic remain as before.

## Manual Godot 4.7 checklist

1. Import/open the project and check for parser, resource or shader errors. Open Mango, Pepsin and both weapon visuals; inspect the scene groups and editor previews.
2. Compare each character's front, side, back and three-quarter views to its approved sheet. Review Pepsin visor/ears/cap, Mango backpack joins/straps and rounded boot silhouettes.
3. Run main and weapon_test. Check movement/sprint/jump, camera switching, capture/release and existing collisions.
4. In FPS and TPS, inspect loaded mango/leaf visibility, pouch contact, release/recoil, empty interval and replacement. Test taps, held fire and camera switching immediately before/after shots.
5. Aim high/low, move/run/jump while firing and stand near walls/shelves. Review hand contact, band endpoints, crosshair clearance and the wall-safe spawn behavior.
6. Verify hits against Pepsin/dummy still deal the expected damage at the existing cadence. Watch repeated hit flashes restore original materials and hit stun cancel Pepsin's windup.
7. Observe idle/moving/aiming/firing Pepsins, cap sway, weapon hand attachment and actual bubble emission from the nozzle. Check visibility from normal combat distance.
8. Take damage in FPS/TPS: verify flinch/weapon jolt, screen-edge pulse and unchanged HUD updates. Healing must not trigger damage feedback.
9. Kill Pepsin: check collapse, immediate collision removal, brief visible body and one defeat event. Confirm encounters/shutters/exit still progress.
10. Let Mango die in both modes: verify the FPS weapon hides, the TPS pose completes despite pause, result UI stays interactive and restart resets reactions/readiness.
11. Check performance during existing encounters and clipping/readability against store backgrounds.

## Remaining approximation

Native surfaces, layered panels and primitive joins remain an approximation rather than sculpted/UV-textured/skinned characters. Ear interiors and visor are layered surfaces, clothing lacks fabric textures, and faces use fixed expressions rather than facial animation. Readability and reference fidelity require in-engine visual review. No unrelated work follows this milestone.

