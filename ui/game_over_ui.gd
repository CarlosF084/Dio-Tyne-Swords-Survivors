class_name GameOverUI
extends CanvasLayer


@export var restart_delay: float = 5.0

@onready var time_label: Label = %TimeLabel
@onready var monsters_label: Label = %MonstersLabel

var restart_cooldown: float

func _ready() -> void:
	time_label.text = GameManager.time_elapsed_str
	monsters_label.text = str(GameManager.monsters_defeated_counter)
	restart_cooldown = restart_delay


func _process(delta: float) -> void:
	restart_cooldown -= delta
	if restart_cooldown <= 0.0:
		restart_game()


func restart_game() -> void:
	GameManager.reset()
	get_tree().reload_current_scene()
