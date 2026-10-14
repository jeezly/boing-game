extends Node
## Bounded pressure with registered scene definitions; no kill-gated phases.
signal enemy_defeated(points: int)
const Definition = preload("res://scripts/game/survival/enemy_definition.gd")
@export var enemy_definitions: Array[Resource] = []
@export var player_path: NodePath
@export var environment_path: NodePath
@export var spawn_manager_path: NodePath
@export var objective_director_path: NodePath
@export var enemy_root_path: NodePath
@onready var player = get_node(player_path)
@onready var environment = get_node(environment_path)
@onready var spawner = get_node(spawn_manager_path)
@onready var objectives = get_node(objective_director_path)
@onready var enemy_root: Node3D = get_node(enemy_root_path)
const STARTS: Array[float] = [0.0, 120.0, 240.0, 360.0, 480.0, 540.0]
const CAPS: Array[int] = [8, 10, 14, 18, 20, 22]
const INTERVALS: Array[float] = [3.4, 2.8, 2.3, 1.7, 1.25, 0.95]
const BATCHES: Array[int] = [1, 1, 2, 2, 2, 3]
var living: Dictionary = {}
var running: bool = false
var elapsed: float = 0.0
var spawn_left: float = 0.6
var cleanup_left: float = 1.0
var serial: int = 0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

func register_definition(definition: Definition) -> void:
	if definition != null and definition.enemy_scene != null and not enemy_definitions.has(definition):
		enemy_definitions.append(definition)

func start() -> void:
	if running: return
	running = true
	spawn_left = 0.6

func stop() -> void:
	running = false
	for enemy in living.values():
		if is_instance_valid(enemy) and enemy.has_method("deactivate"): enemy.deactivate()

func set_elapsed(seconds: float) -> void:
	elapsed = seconds

func _physics_process(delta: float) -> void:
	if not running or player.hp <= 0.0: return
	cleanup_left -= delta
	if cleanup_left <= 0.0:
		cleanup_left = 1.0
		for id in living.keys():
			var enemy = living[id]
			if not is_instance_valid(enemy):
				living.erase(id)
			elif enemy.global_position.distance_to(player.global_position) > 78.0:
				# Recycle distant pressure without awarding kills or score.
				living.erase(id)
				enemy.queue_free()
	spawn_left -= delta
	if spawn_left > 0.0: return
	var stage := 0
	for index in range(STARTS.size()):
		if elapsed >= STARTS[index]: stage = index
	if living.size() >= CAPS[stage]:
		spawn_left = 0.4
		return
	var spawned := 0
	for _attempt in range(mini(BATCHES[stage], CAPS[stage] - living.size())):
		var marker: Marker3D = spawner.choose(objectives.active_zone(), objectives.neighboring_zones(), living.values(), elapsed)
		if marker == null: break
		var definition := _select_definition()
		if definition == null: break
		_spawn(definition, marker.global_position)
		spawned += 1
	spawn_left = INTERVALS[stage] if spawned > 0 else 0.35

func _select_definition() -> Definition:
	var total: float = 0.0
	for resource in enemy_definitions:
		var definition := resource as Definition
		if definition != null and definition.enemy_scene != null: total += definition.selection_weight
	if total <= 0.0: return null
	var roll := rng.randf() * total
	for resource in enemy_definitions:
		var definition := resource as Definition
		if definition == null or definition.enemy_scene == null: continue
		roll -= definition.selection_weight
		if roll <= 0.0: return definition
	return null

func _spawn(definition: Definition, point: Vector3) -> void:
	var enemy = definition.enemy_scene.instantiate()
	if not enemy.has_method("activate") or not enemy.has_signal("defeated"):
		push_error("Enemy definition must provide activate() and defeated.")
		enemy.queue_free()
		return
	enemy.position = enemy_root.to_local(point)
	var id: int = enemy.get_instance_id()
	living[id] = enemy
	enemy.defeated.connect(_on_defeated.bind(id, definition.kill_score))
	enemy.tree_exited.connect(_on_removed.bind(id))
	enemy_root.add_child(enemy)
	enemy.activate(player, environment, serial % 6)
	serial += 1

func _on_defeated(_enemy: CharacterBody3D, id: int, points: int) -> void:
	if not living.has(id): return
	living.erase(id)
	if running: enemy_defeated.emit(points)

func _on_removed(id: int) -> void:
	living.erase(id)
