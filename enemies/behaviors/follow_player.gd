extends Node


@export var speed: float = 1.0

var enemy: CharacterBody2D
var anim_sprite: AnimatedSprite2D

func _ready() -> void:
	enemy = get_parent()
	anim_sprite = enemy.get_node("AnimatedSprite2D")


func _physics_process(_delta: float) -> void:
	# Ignorar Game Over
	if GameManager.is_game_over:
		return
	
	# Calcula a direção
	var player_position: Vector2 = GameManager.player_position
	var difference = player_position - enemy.position
	var input_vector = difference.normalized()
	
	# Movimento
	enemy.velocity = speed * input_vector * 100.0
	enemy.move_and_slide()
	
	# Girar sprite
	if input_vector.x > 0:
		anim_sprite.flip_h = false
	elif input_vector.x < 0:
		anim_sprite.flip_h = true
