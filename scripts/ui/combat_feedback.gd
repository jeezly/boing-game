extends CanvasLayer
## Camera-independent damage pulse, beneath the existing result UI.
var pulse: float = 0.0
@onready var edges: Control = $edges

func _ready() -> void:
	var player = get_parent()
	player.damaged.connect(_on_damaged)
	edges.modulate.a = 0.0

func _on_damaged(_amount: float) -> void:
	pulse = 0.28

func _process(delta: float) -> void:
	pulse = maxf(0.0, pulse - delta)
	edges.modulate.a = smoothstep(0.0, 0.28, pulse) * 0.55
