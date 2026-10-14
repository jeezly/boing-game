extends Node3D
## Three authored encounters, sequential activation, one clear final exit.

const EnemyScene = preload("res://scenes/enemies/pepsin.tscn")
const PickupScene = preload("res://scenes/game/health_pickup.tscn")
@export var player_path: NodePath = NodePath("../Player")
@export var store_path: NodePath = NodePath("../la_abarrotera")
@onready var player = get_node(player_path)
@onready var store = get_node(store_path)
@onready var objective: Label = $scenario_ui/screen/objective
@onready var notice: Label = $scenario_ui/screen/notice
@onready var result_panel: PanelContainer = $scenario_ui/screen/result_panel
@onready var result_text: Label = $scenario_ui/screen/result_panel/result_layout/result_text
var cleared: int = 0
var remaining: int = 0
var running: bool = false
var finished: bool = false
var notice_time: float = 0.0
var encounters: Array[Array] = [
	[Vector3(-4, 0.05, 1), Vector3(4, 0.05, -1)],
	[Vector3(-8, 0.05, -18), Vector3(0, 0.05, -19), Vector3(8, 0.05, -18)],
	[Vector3(-9, 0.05, -29), Vector3(9, 0.05, -31), Vector3(-7, 0.05, -40), Vector3(8, 0.05, -42)]
]

func _ready() -> void:
	player.died.connect(_player_died)
	$scenario_ui/screen/result_panel/result_layout/restart_button.pressed.connect(_restart)
	result_panel.hide()
	objective.text = "LA ABARROTERA\nEntra a la tienda y despeja el barrio"
	_message("WASD  /  SHIFT correr  /  ESPACIO saltar\nClic disparar  /  V FPS-TPS  /  ESC liberar mouse", 7.0)
	for point in [Vector3(0, 0, -4), Vector3(10, 0, -26.5), Vector3(1.5, 0, -39)]:
		var pickup := PickupScene.instantiate() as Area3D
		get_parent().add_child.call_deferred(pickup)
		pickup.position = point

func _process(delta: float) -> void:
	if finished: return
	notice_time = maxf(0.0, notice_time - delta)
	if notice_time == 0.0: notice.text = ""
	if running: return
	var z: float = player.global_position.z
	if (cleared == 0 and z < 7.0) or (cleared == 1 and z < -8.0) or (cleared == 2 and z < -26.0):
		_start_encounter()
	elif cleared == 3 and z < -43.0:
		_finish(true)

func _start_encounter() -> void:
	running = true
	remaining = encounters[cleared].size()
	var titles := ["Primer combate / zona de cajas", "Pasillos y refrigeradores", "Bodega y patio de carga"]
	_message(titles[cleared], 3.0)
	_update_objective()
	for index in range(remaining):
		var enemy = EnemyScene.instantiate()
		# Spawn outside this always-processing UI manager so pause stops enemy logic.
		get_tree().current_scene.add_child(enemy)
		enemy.global_position = encounters[cleared][index]
		enemy.defeated.connect(_enemy_defeated)
		enemy.activate(player, store, index)

func _enemy_defeated(_enemy: CharacterBody3D) -> void:
	if finished: return
	remaining = maxi(0, remaining - 1)
	_update_objective()
	if remaining != 0: return
	running = false
	cleared += 1
	if cleared == 1:
		objective.text = "CAJAS DESPEJADAS\nAvanza hacia los pasillos del fondo"
	elif cleared == 2:
		store.open_bodega()
		objective.text = "PASILLOS DESPEJADOS\nEntra a la bodega por cualquiera de sus dos accesos"
	else:
		objective.text = "ABARROTERA DESPEJADA\nLlega a la salida al fondo del patio"
	_message("Encuentro despejado / busca suministros de salud", 3.5)

func _update_objective() -> void:
	objective.text = "ENCUENTRO %d / 3\nPepsins restantes: %d" % [cleared + 1, remaining]

func _message(text: String, seconds: float) -> void:
	notice.text = text
	notice_time = seconds

func _player_died() -> void:
	_finish(false)

func _finish(won: bool) -> void:
	if finished: return
	finished = true
	result_text.text = "BARRIO A SALVO\nLa Abarrotera esta despejada" if won else "MANGO CAYO\nVuelve a intentarlo"
	result_panel.show()
	$scenario_ui/screen/result_panel/result_layout/restart_button.grab_focus()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true

func _unhandled_input(event: InputEvent) -> void:
	if finished and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_R:
		get_viewport().set_input_as_handled()
		_restart()

func _restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene.call_deferred()
