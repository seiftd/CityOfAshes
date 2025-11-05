extends CharacterBody2D

## Gangster Enemy - عدو مسلح
## يهاجم اللاعب من مسافة بعيدة

@export var speed: float = 40.0
@export var health: int = 75
@export var damage: int = 15
@export var detection_range: float = 300.0
@export var attack_range: float = 250.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_timer: Timer = $AttackTimer

var player: Node2D = null
var direction: int = -1
var is_attacking: bool = false
var is_dead: bool = false

func _ready():
	if sprite:
		sprite.play("Idle")
	
	if detection_area:
		var collision = detection_area.get_node_or_null("CollisionShape2D")
		if collision:
			var circle_shape = CircleShape2D.new()
			circle_shape.radius = detection_range
			collision.shape = circle_shape
		
		detection_area.body_entered.connect(_on_player_detected)
		detection_area.body_exited.connect(_on_player_lost)
	
	if attack_timer:
		attack_timer.timeout.connect(_on_attack_timer_timeout)

func _physics_process(delta):
	if is_dead:
		return
	
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	
	if player and not is_attacking:
		var distance_to_player = global_position.distance_to(player.global_position)
		
		if distance_to_player <= detection_range:
			direction = 1 if player.global_position.x > global_position.x else -1
			
			if distance_to_player <= attack_range:
				_attack()
			else:
				_move_towards_player()
		else:
			_wander()
	
	var gravity_value = ProjectSettings.get_setting("physics/2d/default_gravity", 980.0)
	velocity.y += gravity_value * delta
	move_and_slide()
	
	if sprite and direction != 0:
		sprite.flip_h = direction > 0

func _move_towards_player():
	if player:
		var direction_to_player = sign(player.global_position.x - global_position.x)
		velocity.x = direction_to_player * speed
		if sprite:
			sprite.play("Run")

func _wander():
	velocity.x = direction * speed * 0.5
	if sprite:
		sprite.play("Idle")
	
	if randf() < 0.01:
		direction *= -1

func _attack():
	if is_attacking:
		return
	
	is_attacking = true
	velocity.x = 0
	
	if sprite:
		sprite.play("Attack")
	
	# إطلاق النار
	_shoot_at_player()
	
	if attack_timer:
		attack_timer.start(1.5)

func _shoot_at_player():
	if player:
		# إصدار صوت الطلقة
		var audio_player = get_node_or_null("AudioStreamPlayer2D")
		if audio_player:
			var shoot_sound = preload("res://assets/sfx/gunshot_pistol.mp3")
			if shoot_sound:
				audio_player.stream = shoot_sound
				audio_player.play()
		
		# TODO: إضافة Projectile هنا

func take_damage(amount: int):
	health -= amount
	
	if sprite:
		sprite.play("Hurt")
	
	if health <= 0:
		_die()

func _die():
	if is_dead:
		return
	
	is_dead = true
	velocity = Vector2.ZERO
	
	if sprite:
		sprite.play("Dead")
	
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _on_player_detected(body: Node2D):
	if body.is_in_group("player"):
		player = body

func _on_player_lost(body: Node2D):
	if body == player:
		player = null

func _on_attack_timer_timeout():
	is_attacking = false

