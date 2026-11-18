extends SceneTree
## Store refactor regression: routes, zone contracts and overhead pose geometry.
var checks: int = 0
var failures: Array[String] = []
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
 checks += 1
 if not ok:
  failures.append(message)
  push_error(message)
func count_collision(node: Node) -> int:
 var count := 1 if node is CollisionObject3D or node is CollisionShape3D else 0
 for child in node.get_children(): count += count_collision(child)
 return count
func run() -> void:
 var game: Node3D = load("res://scenes/game/main.tscn").instantiate()
 root.add_child(game)
 current_scene = game
 for i in range(5): await physics_frame
 var store = game.get_node("mega_abarrotera")
 var match_state = game.get_node("match_controller")
 match_state.director.running = false
 check(store.zones.size() == 7, "all seven combat zones indexed")
 check(count_collision(store.get_node("store_finish")) == 0, "finish adds no ground collision or navigation obstacles")
 var origin := Vector3(0, 0.05, -2)
 for marker in store.get_node("respawn_points").get_children():
  check(not store.get_navigation_path(origin, marker.global_position).is_empty(), "connected respawn: " + marker.name)
 for marker in store.spawn_markers:
  check(not store.get_navigation_path(origin, marker.global_position).is_empty(), "connected enemy spawn: " + marker.name)
 for marker in store.get_node("objective_markers").get_children():
  check(not store.get_navigation_path(origin, marker.global_position).is_empty(), "connected objective: " + marker.name)
 check(store.entrance.body_entered.is_connected(store._on_entrance), "entrance callback preserved")
 check(store.get_node("healing_station/body").is_in_group("navigation_obstacle"), "shop collision indexed")
 check(not match_state.respawns._clear_geometry(Vector3(-62, 0.05, -75.7)), "truck cab remains solid")
 check(ProjectSettings.get_setting("rendering/renderer/rendering_method") == "gl_compatibility", "Compatibility retained")
 check(ProjectSettings.get_setting("physics/3d/physics_engine") == "Jolt Physics", "Jolt retained")
 var polar = load("res://scripts/enemies/polar/polar_visual.gd").new()
 game.add_child(polar)
 for i in range(40): polar.present(1.0 / 60.0, 0, 0.65, false)
 for arm in polar.arms:
  var raised: Vector3 = arm.global_transform * Vector3(0, -0.51, -0.09)
  check(raised.y > 1.65, "anticipation raises paw above head")
 for i in range(8): polar.present(1.0 / 60.0, 0, -1, true)
 for arm in polar.arms:
  var lowered: Vector3 = arm.global_transform * Vector3(0, -0.51, -0.09)
  check(lowered.y < 1.05 and lowered.z < -0.25, "downstroke carries paw downward and forward")
 print("ENVIRONMENT_POLISH_AUDIT: %d checks, %d failures" % [checks, failures.size()])
 quit(0 if failures.is_empty() else 1)
