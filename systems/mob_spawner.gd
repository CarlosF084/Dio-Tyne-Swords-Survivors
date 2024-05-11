class_name MobSpawner
extends Node2D


@export var creatures: Array[PackedScene]
var mobs_per_minute: float = 60.0

var cooldown: float = 0.0
var time: float = 0.0

@onready var path_2d: Path2D = %Path2D
@onready var path_follow_2d: PathFollow2D = %PathFollow2D

func _ready() -> void:
	var margin_h: float = 1152.0 / 2.0 + 64.0
	var margin_v: float = 648.0 / 2.0 + 64.0
	path_2d.curve.add_point(Vector2(-margin_h, -margin_v)) # TopLeft
	path_2d.curve.add_point(Vector2(margin_h, -margin_v)) # TopRight
	path_2d.curve.add_point(Vector2(margin_h, margin_v)) # BottomRight
	path_2d.curve.add_point(Vector2(-margin_h, margin_v)) # BottomLeft
	path_2d.curve.add_point(Vector2(-margin_h, -margin_v)) # TopLeft


func _process(delta: float) -> void:
	# Temporizador
	cooldown -= delta
	if cooldown > 0:
		return
	
	# Frequencia
	var interval: float = 60.0 / mobs_per_minute
	cooldown = interval
	
	# Checar se o ponto é válido
	var point = get_point()
	var world_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = point
	parameters.collision_mask = 0b1001
	var result: Array = world_state.intersect_point(parameters, 1)
	if not result.is_empty():
		return
	
	# Instanciar uma criatura aleátoria
	var index: int = randi_range(0, creatures.size() - 1)
	var creature_scene = creatures[index]
	var creature: Enemy = creature_scene.instantiate()
	creature.global_position = get_point()
	get_parent().add_child(creature)


func get_point() -> Vector2:
	path_follow_2d.progress_ratio = randf()
	return path_follow_2d.global_position
