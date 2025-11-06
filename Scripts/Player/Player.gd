extends CharacterBody2D

## Player - اللاعب الرئيسي
## يدير الحركة، القفز، إطلاق النار، والصحة

@export var speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var max_health: int = 100
@export var max_ammo: int = 30

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var gun: Node2D = $Gun
@onready var shoot_timer: Timer = $ShootTimer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var health: int = 100
var ammo: int = 30
var is_dead: bool = false
var can_shoot: bool = true

signal health_changed(new_health: int)
signal ammo_changed(new_ammo: int)
signal player_died

func _ready():
	health = max_health
	ammo = max_ammo
	add_to_group("player")
	
	if sprite:
		sprite.play("Idle")
	
	if shoot_timer:
		shoot_timer.timeout.connect(_on_shoot_timer_timeout)

func _physics_process(delta):
	if is_dead:
		return
	
	# Handle jump
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_velocity
			if sprite:
				sprite.play("Jump")
	
	# Handle horizontal movement
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * speed
		if sprite and is_on_floor():
			sprite.play("Walk")
		if sprite:
			sprite.flip_h = direction > 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		if sprite and is_on_floor():
			sprite.play("Idle")
	
	# Handle shooting
	if Input.is_action_pressed("shoot") and can_shoot and ammo > 0:
		_shoot()
	
	# Apply gravity
	var gravity_value = ProjectSettings.get_setting("physics/2d/default_gravity", 980.0)
	if not is_on_floor():
		velocity.y += gravity_value * delta
		if sprite and velocity.y > 0:
			sprite.play("Fall")
	
	move_and_slide()

func _shoot():
	if not can_shoot or ammo <= 0:
		return
	
	can_shoot = false
	ammo -= 1
	ammo_changed.emit(ammo)
	
	if sprite:
		sprite.play("Shoot")
	
	# Play shoot sound
	if audio_player:
		var shoot_sound = load("res://assets/sfx/gunshot_pistol.mp3")
		if shoot_sound:
			audio_player.stream = shoot_sound
			audio_player.play()
	
	# Spawn bullet
	if gun:
		_spawn_bullet()
	
	# Reset shoot timer
	if shoot_timer:
		shoot_timer.start(0.2)

func _spawn_bullet():
	var bullet_scene = preload("res://Scenes/Entities/Bullet.tscn")
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		
		# Set bullet position and direction
		var shoot_direction = 1 if sprite.flip_h else -1
		bullet.global_position = gun.global_position
		bullet.direction = Vector2(shoot_direction, 0)

func take_damage(amount: int):
	if is_dead:
		return
	
	health -= amount
	health = max(0, health)
	health_changed.emit(health)
	
	if sprite:
		sprite.play("Hurt")
	
	if health <= 0:
		_die()

func heal(amount: int):
	health = min(max_health, health + amount)
	health_changed.emit(health)

func add_ammo(amount: int):
	ammo = min(max_ammo, ammo + amount)
	ammo_changed.emit(ammo)

func _die():
	if is_dead:
		return
	
	is_dead = true
	velocity = Vector2.ZERO
	
	if sprite:
		sprite.play("Dead")
	
	player_died.emit()
	
	# Transition to game over after delay
	await get_tree().create_timer(2.0).timeout
	if GameManager:
		GameManager.player_died.emit()
		GameManager.goto_game_over()
	else:
		# Fallback if GameManager not available
		get_tree().change_scene_to_file("res://Scenes/UI/GameOver.tscn")

func _on_shoot_timer_timeout():
	can_shoot = true

