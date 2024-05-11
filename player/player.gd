class_name Player
extends CharacterBody2D


signal meat_collected(value: int)

@export_category("Atributos")
@export var health: int = 100
@export var max_health: int = 100
@export var sword_damage: int = 2
@export var speed: float = 300.0

@export_category("Ritual")
@export var ritual_damage: int = 1
@export var ritual_interval: float = 30.0

@export_category("Preload")
@export var death_prefab: PackedScene
@export var ritual_scene: PackedScene

var input_vector: Vector2 
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0
var ritual_cooldown: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var health_progress_bar: ProgressBar = $HealthProgressBar

func _ready() -> void:
	GameManager.player = self
	meat_collected.connect(func(_value: int):
		GameManager.meat_counter += 1
	)


func _process(delta: float) -> void:
	GameManager.player_position = position
	
	# Ler input
	read_input()
	
	# Processar ataque
	update_attack_cooldown(delta)
	if Input.is_action_just_pressed("attack"):
		attack()
	
	# Processar animação e rotação de sprite
	play_run_idle_animation()
	if not is_attacking:
		rotate_sprite()
	
	# Processar dano
	update_hitbox_detection(delta)
	
	# Ritual
	update_ritual(delta)
	
	# Atualizar health bar
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health


func _physics_process(_delta: float) -> void:
	# Modificar a velocidade
	var target_velocity: Vector2 = input_vector * speed
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity, 0.05)
	move_and_slide()


func update_attack_cooldown(delta: float) -> void:
	# Atualizar temporizador do ataque
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")


func update_ritual(delta: float) -> void:
	# Atualizar temporizador
	ritual_cooldown -= delta
	if ritual_cooldown > 0:
		return
	ritual_cooldown = ritual_interval
	
	# Criar ritual
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)


func read_input() -> void:
	# Obter o input vector
	input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Apagar deadzone do input vector
	var deadzone: float = 0.15
	if abs(input_vector.x) < deadzone:
		input_vector.x = 0.0
	if abs(input_vector.y) < deadzone:
		input_vector.y = 0.0
	
	# Atualizar o is_running
	was_running = is_running
	is_running = not input_vector.is_zero_approx()


func play_run_idle_animation() -> void:
	# Tocar animação
	if was_running != is_running:
		if is_running:
			animation_player.play("run")
		else:
			animation_player.play("idle")


func rotate_sprite() -> void:
	# Girar sprite
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true


func attack() -> void:
	if is_attacking:
		return
	
	# Tocar animação
	animation_player.play("attack_side_1")
	
	# Configurar temporizador
	attack_cooldown = 0.6
	
	# Marca ataque
	is_attacking = true


func deal_damage_to_enemies() -> void:
	var bodies: Array[Node2D] = sword_area.get_overlapping_bodies()
	for body: Node2D in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			
			var enemy_direction: Vector2 = (enemy.position - position).normalized()
			var attack_direction: Vector2
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			
			var dot_product: float = enemy_direction.dot(attack_direction)
			if dot_product >= 0.3:
				enemy.damage(sword_damage)


func update_hitbox_detection(delta: float) -> void:
	# Temporizador
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0:
		return
	
	# Frequencia
	hitbox_cooldown = 0.5
	
	var bodies: Array[Node2D] = hitbox_area.get_overlapping_bodies()
	for body: Node2D in bodies:
		if body.is_in_group("enemies"):
			var _enemy: Enemy = body
			var damage_amount: int = 1
			damage(damage_amount)


func damage(amount: int) -> void:
	if health <= 0:
		return
	
	health -= amount
	
	# Piscar node
	modulate = Color.RED
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	if health <= 0:
		die()


func die() -> void:
	GameManager.end_game()
	
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	queue_free()


func heal(amount: int) -> void:
	health += amount
	if health > max_health:
		health = max_health
