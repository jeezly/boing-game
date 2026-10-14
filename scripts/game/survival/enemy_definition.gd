extends Resource
## Registry entry; the director depends on activate/defeated, not a concrete enemy class.
@export var enemy_scene: PackedScene
@export_range(1, 10000) var kill_score: int = 100
@export_range(0.01, 100.0) var selection_weight: float = 1.0
