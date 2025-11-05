extends CanvasLayer

## LevelHUD - واجهة المستخدم للمستوى
## يعرض التعليمات والتدريب

@onready var tutorial_label: Label = $TutorialLabel
@onready var fade_tween: Tween

var tutorial_messages = [
	"Use Left/Right arrows to move",
	"Press Jump to leap over obstacles",
	"Tap Fire to shoot enemies"
]
var current_message_index: int = 0

func _ready():
	if tutorial_label:
		tutorial_label.text = tutorial_messages[0]
		tutorial_label.modulate.a = 1.0
		
		# إخفاء التعليمات بعد 10 ثواني
		await get_tree().create_timer(10.0).timeout
		_fade_out_tutorial()

func _fade_out_tutorial():
	if tutorial_label:
		fade_tween = create_tween()
		fade_tween.tween_property(tutorial_label, "modulate:a", 0.0, 1.0)
		fade_tween.tween_callback(func(): tutorial_label.visible = false)

func show_message(message: String, duration: float = 3.0):
	if tutorial_label:
		tutorial_label.text = message
		tutorial_label.modulate.a = 1.0
		tutorial_label.visible = true
		
		await get_tree().create_timer(duration).timeout
		_fade_out_tutorial()

