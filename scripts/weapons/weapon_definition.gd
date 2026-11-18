extends Resource
## Immutable catalogue data. Ownership, ammunition and equip belong to the arsenal.
@export var id: StringName
@export var behavior: StringName
@export var presentation_key: StringName
@export var display_name: String
@export var pro_name: String
@export_multiline var description: String
@export var damage: float = 25.0
@export var pro_damage: float = 25.0
@export var cooldown: float = 1.0
@export var speed: float = 24.0
@export var reach: float = 25.0
@export var radius: float = 0.0
@export var max_ammo: int = -1
@export var price: int = 0
@export var upgrade_price: int = 0
@export var available: bool = true
