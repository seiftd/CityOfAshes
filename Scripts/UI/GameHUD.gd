extends CanvasLayer

## GameHUD - واجهة المستخدم أثناء اللعب
## يعرض الصحة، الذخيرة، الموجة، وزر الإيقاف

@onready var health_bar: ProgressBar = $HUDContainer/HealthBar
@onready var health_label: Label = $HUDContainer/HealthLabel
@onready var ammo_label: Label = $HUDContainer/AmmoLabel
@onready var wave_label: Label = $HUDContainer/WaveLabel
@onready var pause_button: Button = $HUDContainer/PauseButton

var player: Node2D = null

func _ready():
	# Wait a frame for player to be ready
	await get_tree().process_frame
	
	# Find player
	player = get_tree().get_first_node_in_group("player")
	
	if player:
		# Connect signals
		if player.has_signal("health_changed"):
			player.health_changed.connect(_on_health_changed)
		if player.has_signal("ammo_changed"):
			player.ammo_changed.connect(_on_ammo_changed)
		
		# Initialize values
		if health_bar:
			health_bar.max_value = player.max_health if player.has("max_health") else 100
			health_bar.value = player.health if player.has("health") else 100
		
		if health_label:
			var max_hp = player.max_health if player.has("max_health") else 100
			var hp = player.health if player.has("health") else 100
			health_label.text = "Health: " + str(hp) + "/" + str(max_hp)
		
		if ammo_label:
			var ammo = player.ammo if player.has("ammo") else 30
			ammo_label.text = "Ammo: " + str(ammo)
	
	# Update wave
	if wave_label and GameManager:
		wave_label.text = "Wave: " + str(GameManager.current_wave)
	
	# Connect pause button
	if pause_button:
		pause_button.pressed.connect(_on_pause_pressed)

func _on_health_changed(new_health: int):
	if health_bar:
		health_bar.value = new_health
	if health_label:
		var max_health = 100
		if player and player.has_method("get") and player.get("max_health"):
			max_health = player.max_health
		health_label.text = str(new_health) + "/" + str(max_health)

func _on_ammo_changed(new_ammo: int):
	if ammo_label:
		ammo_label.text = "Ammo: " + str(new_ammo)

func _on_pause_pressed():
	var pause_path = "res://Scenes/UI/PauseMenu.tscn"
	if ResourceLoader.exists(pause_path):
		get_tree().paused = true
		var pause_menu = load(pause_path).instantiate()
		add_child(pause_menu)
	else:
		print("PauseMenu scene not found")

