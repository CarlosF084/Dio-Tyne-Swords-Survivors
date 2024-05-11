extends Node2D


@export var game_over_ui_template: PackedScene

@onready var game_ui: CanvasLayer = $GameUi

func _ready() -> void:
	GameManager.game_over.connect(trigger_game_over)


func trigger_game_over() -> void:
	# Deletar GameUI
	game_ui.queue_free()
	
	# Criar GameOverUI
	var game_over_ui: GameOverUI = game_over_ui_template.instantiate()
	add_child(game_over_ui)
