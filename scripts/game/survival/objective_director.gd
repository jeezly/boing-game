extends Node
## Time-driven phases; participation cannot stall the clock.
signal objective_changed(zone: StringName, text: String, phase: int)
signal phase_bonus_awarded(points: int)
@export var environment_path: NodePath
@export var player_path: NodePath
@onready var environment = get_node(environment_path)
@onready var player = get_node(player_path)
const ZONES: Array[StringName] = [&"cajas", &"pasillos", &"refrigeradores", &"frutas", &"bodega", &"patio", &"patio"]
const TEXTS: Array[String] = ["ZONA CALIENTE: CAJAS", "ZONA CALIENTE: PASILLOS CENTRALES", "ZONA CALIENTE: REFRIGERADORES", "ZONA CALIENTE: FRUTAS Y GRANEL", "ZONA CALIENTE: BODEGA", "ZONA CALIENTE: PATIO DE CARGA", "¡DESMADRE FINAL! SOBREVIVE"]
const ENDS: Array[float] = [510.0, 420.0, 330.0, 240.0, 150.0, 60.0, 0.0]
var phase: int = -1
var participated: bool = false
var running: bool = false

func begin() -> void:
	if running: return
	running = true
	_enter_phase(0)

func advance(remaining: float) -> void:
	if not running: return
	_sample_participation()
	while phase < ZONES.size() - 1 and remaining <= ENDS[phase]:
		_complete_phase()
		_enter_phase(phase + 1)
	_sample_participation()

func finish() -> void:
	if not running: return
	_sample_participation()
	_complete_phase()
	running = false

func stop() -> void:
	running = false

func _enter_phase(index: int) -> void:
	phase = index
	participated = false
	environment.set_objective(active_zone(), TEXTS[phase])
	_sample_participation()
	objective_changed.emit(active_zone(), TEXTS[phase], phase)

func _sample_participation() -> void:
	if phase >= 0 and environment.contains_zone(active_zone(), player.global_position):
		participated = true

func _complete_phase() -> void:
	if participated: phase_bonus_awarded.emit(500)
	participated = false

func active_zone() -> StringName:
	return ZONES[phase] if phase >= 0 else &"entrance"

func player_inside() -> bool:
	return phase >= 0 and environment.contains_zone(active_zone(), player.global_position)

func objective_text() -> String:
	return TEXTS[phase] if phase >= 0 else "ENTRA A LA ABARROTERA"

func neighboring_zones() -> Array[StringName]:
	match active_zone():
		&"cajas": return [&"pasillos", &"refrigeradores", &"frutas"]
		&"pasillos": return [&"cajas", &"refrigeradores", &"frutas", &"bodega"]
		&"refrigeradores": return [&"pasillos", &"cajas", &"patio"]
		&"frutas": return [&"pasillos", &"bodega"]
		&"bodega": return [&"patio", &"frutas", &"pasillos"]
		&"patio": return [&"bodega", &"refrigeradores", &"pasillos"]
	return []
