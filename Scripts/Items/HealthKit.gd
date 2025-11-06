extends Area2D

## HealthKit - علبة صحية
## تعيد صحة اللاعب عند التقاطها

@export var heal_amount: int = 25

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	body_entered.connect(_on_body_entered)
	
	if sprite:
		sprite.play("Idle")

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		if body.has_method("heal"):
			body.heal(heal_amount)
		
		# Play pickup sound
		var audio = AudioStreamPlayer2D.new()
		audio.stream = load("res://assets/sfx/item_pickup.mp3")
		audio.bus = "SFX"
		add_child(audio)
		audio.play()
		
		# Remove item
		queue_free()

