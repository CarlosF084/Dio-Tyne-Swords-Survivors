extends CanvasLayer


@onready var timer_label: Label = %TimerLabel
@onready var meat_label: Label = %MeatLabel

func _process(_delta: float) -> void:
	# Update labels
	timer_label.text = GameManager.time_elapsed_str
	meat_label.text = str(GameManager.meat_counter)
