extends Node3D
@export var offer: Resource
var match_controller: Node
var player: CharacterBody3D
var prompt_visible: bool = false

func _ready() -> void:
	_bind.call_deferred()

func _bind() -> void:
	match_controller = get_tree().get_first_node_in_group("match_controller")
	player = get_tree().get_first_node_in_group("player")

func is_available(customer: CharacterBody3D) -> bool:
	if customer.hp <= 0.0 or not customer.combat_enabled: return false
	if customer.global_position.distance_to(global_position) > 3.3: return false
	var query := PhysicsRayQueryParameters3D.create(customer.global_position + Vector3.UP, global_position + Vector3.UP * 1.7, 1, [get_node("body").get_rid()])
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(match_controller) or not is_instance_valid(player): return
	var available: bool = match_controller.state_name() == "PLAYING" and is_available(player)
	if available != prompt_visible:
		prompt_visible = available
		match_controller.interaction_changed.emit("[E] COMPRAR CURACIÓN — %d CRÉDITOS" % offer.cost if available else "")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not event.is_echo() and prompt_visible:
		match_controller.purchase_service(self)
		get_viewport().set_input_as_handled()
