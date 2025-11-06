extends Area2D

## Bullet - رصاصة اللاعب
## تتحرك في اتجاه معين وتسبب ضرر للأعداء

@export var speed: float = 500.0
@export var damage: int = 25
@export var lifetime: float = 2.0

var direction: Vector2 = Vector2.RIGHT

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	# Set up collision
	body_entered.connect(_on_body_entered)
	
	# Auto-destroy after lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	global_position += direction * speed * delta
	
	# Rotate bullet to face direction
	if sprite:
		sprite.rotation = direction.angle()

func _on_body_entered(body: Node2D):
	if body.is_in_group("enemies"):
		# Damage enemy
		if body.has_method("take_damage"):
			body.take_damage(damage)
		
		# Create explosion effect
		_create_explosion()
		
		# Remove bullet
		queue_free()
	elif body.is_in_group("player"):
		# Don't hit player
		pass
	else:
		# Hit wall or obstacle
		_create_explosion()
		queue_free()

func _create_explosion():
	# Play explosion sound
	var audio = AudioStreamPlayer2D.new()
	audio.stream = load("res://assets/sfx/explosion_small.mp3")
	audio.bus = "SFX"
	add_child(audio)
	audio.play()
	await audio.finished
	audio.queue_free()

