class_name Enemy
extends Node2D


const PreDamageDigit: PackedScene = preload("res://misc/damage_digit.tscn")

@export_category("Life")
@export var health: int = 10
@export var death_prefab: PackedScene

@export_category("Drops")
@export var drop_chance: float = 0.1
@export var drop_items: Array[PackedScene]
@export var drop_chances: Array[float]

@onready var damage_digit_marker: Marker2D = $DamageDigitMarker

func damage(amount: int) -> void:
	health -= amount
	
	# Piscar node
	modulate = Color.RED
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	# Criar DamageDigit
	var damage_digit: Node2D = PreDamageDigit.instantiate()
	damage_digit.value = amount
	damage_digit.global_position = damage_digit_marker.global_position
	get_parent().add_child(damage_digit)
	
	# Processar morte
	if health <= 0:
		die()


func die() -> void:
	# Caveira
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	
	# Drop
	if randf() <= drop_chance:
		spawn_drop_item()
	
	# Incrementar contador
	GameManager.monsters_defeated_counter += 1
	
	# Deletar node
	queue_free()


func spawn_drop_item() -> void:
	var drop = get_random_drop_item().instantiate()
	drop.position = position
	get_parent().add_child(drop)


func get_random_drop_item() -> PackedScene:
	# Lista com 1 item
	if drop_items.size() == 1:
		return drop_items[0]
	
	# Calcular chance máxima
	var max_chance: float = 0.0
	for chance: float in drop_chances:
		max_chance += drop_chance
	
	# Jogar dado
	var random_value: float = randf() * max_chance
	
	# Girar roleta
	var needle: float = 0.0
	for i in drop_items.size():
		var drop_item: PackedScene = drop_items[i]
		var chance: float = drop_chances[i] if i < drop_chances.size() else 1.0
		
		if random_value <= chance + needle:
			return drop_item
		needle += chance
	return drop_items[0]
