extends CharacterBody2D

## Zombie Enemy - عدو زومبي متجول
## يتحرك يميناً ويساراً ويهاجم اللاعب عند اقترابه

@export var speed: float = 30.0
@export var health: int = 50
@export var damage: int = 10
@export var detection_range: float = 200.0
@export var attack_range: float = 50.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_timer: Timer = $AttackTimer

var player: Node2D = null
var direction: int = -1  # -1 يسار, 1 يمين
var is_attacking: bool = false
var is_dead: bool = false

func _ready():
	add_to_group("enemies")
	
	# إعداد Animation
	if sprite:
		sprite.play("Idle")
	
	# إعداد Detection Area
	if detection_area:
		var collision = detection_area.get_node_or_null("CollisionShape2D")
		if collision:
			var circle_shape = CircleShape2D.new()
			circle_shape.radius = detection_range
			collision.shape = circle_shape
		
		detection_area.body_entered.connect(_on_player_detected)
		detection_area.body_exited.connect(_on_player_lost)

func _physics_process(delta):
	if is_dead:
		return
	
	# البحث عن اللاعب
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	
	if player and not is_attacking:
		var distance_to_player = global_position.distance_to(player.global_position)
		
		if distance_to_player <= detection_range:
			# التوجه نحو اللاعب
			direction = 1 if player.global_position.x > global_position.x else -1
			
			if distance_to_player <= attack_range:
				_attack()
			else:
				_move_towards_player()
		else:
			# التحرك العشوائي
			_wander()
	
	# تطبيق الجاذبية والحركة
	var gravity_value = ProjectSettings.get_setting("physics/2d/default_gravity", 980.0)
	velocity.y += gravity_value * delta
	move_and_slide()
	
	# تحديث اتجاه الـ sprite
	if sprite and direction != 0:
		sprite.flip_h = direction > 0

func _move_towards_player():
	if player:
		var direction_to_player = sign(player.global_position.x - global_position.x)
		velocity.x = direction_to_player * speed
		if sprite:
			sprite.play("Walk")

func _wander():
	velocity.x = direction * speed * 0.5
	if sprite:
		sprite.play("Walk")
	
	# تغيير الاتجاه بشكل عشوائي
	if randf() < 0.01:
		direction *= -1

func _attack():
	if is_attacking:
		return
	
	is_attacking = true
	velocity.x = 0
	
	if sprite:
		sprite.play("Attack")
	
	# إصدار صوت الهجوم
	var audio_player = get_node_or_null("AudioStreamPlayer2D")
	if audio_player:
		var attack_sound = preload("res://assets/sfx/zombie_attack.mp3")
		if attack_sound:
			audio_player.stream = attack_sound
			audio_player.play()

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
	
	# إزالة Collision بعد الموت
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	
	# Notify GameManager
	if GameManager:
		GameManager.on_enemy_killed()
	
	# إزالة العدو بعد ثانيتين
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _on_player_detected(body: Node2D):
	if body.is_in_group("player"):
		player = body

func _on_player_lost(body: Node2D):
	if body == player:
		player = null

