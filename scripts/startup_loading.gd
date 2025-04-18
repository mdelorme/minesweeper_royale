extends Node2D

var is_loading: bool = true
var waiting_progress: float = 0.0
var waiting_speed: float = 10.0
var waiting_goal: float = 25.0
var loading_progress: float = 0.0
var loading_speed: float = 20.0

var last_index: int = -1

var tips: Array[String] = [
	"Tentes de faire exploser tes adversaires !",
	"Un drapeau bien placé est la clé de la réussite !",
	"Un drapeau mal placé et c'est la déchéance !",
	"Gratte le sol... mais pas trop fort, y'a peut-être une mine !",
	"Une poule avertie en vaut deux, surtout quand ça pète !",
	"Qui pose un drapeau récolte la victoire... ou la honte !",
	"La stratégie du poulet ninja est souvent sous-estimée !",
	"Ne cours pas, pense comme une bombe... enfin, pas trop !",
	"Un poule, un drapeau, une explosion : le combo gagnant !",
	"Tu crois que c’est du maïs ? C’est une mine !",
	"Cocorico... BOOM !!",
	"Les vrais poulets ne reculent jamais (sauf quand ça clignote) !",
	"Pose ton drapeau comme tu poses tes limites !",
	"Il ne peut en rester qu’un. Et ce sera peut-être une poule !",
	"Les plumes repoussent, pas la dignité !"
]


@onready var progress_bar = $CanvasLayer/Bottom/ProgressBar
@onready var tips_label = $CanvasLayer/Bottom/Tips/TipsLabel
@onready var tips_audio = $CanvasLayer/Bottom/Tips/TipsAudio


func _process(delta):
	#Simulates a fake loading process using a ProgressBar,
	#with random "waiting" interruptions to make it feel
	#less linear and more dynamic
	if loading_progress < 100.0:
		if is_loading == true:
			if randi() % 80 == 0:
				is_loading = false
				waiting_goal = randf_range(15.0, 30.0)
				return
			loading_progress += loading_speed * delta
			progress_bar.value = loading_progress
		else:
			waiting_progress += waiting_speed * delta
			if waiting_progress >= waiting_goal:
				is_loading = true
				waiting_progress = 0.0
	else:
		loading_progress = 100.0
		get_tree().change_scene_to_file("res://scenes/pregame_lobby.tscn")


func get_random_tips() -> String:
	# 1 tips : return it
	if tips.size() <= 1:
		return tips[0]
	# get new tips
	var _index: int = last_index
	while _index == last_index:
		_index = randi() % tips.size()
	# new tips
	last_index = _index
	return tips[_index]


func update_tips_label() -> void:
	var _new_tips: String = get_random_tips()
	tips_label.text = _new_tips
	tips_audio.pitch_scale = randf_range(0.8, 1.2)
	tips_audio.volume_db = randf_range(0.0, 10.0)
	tips_audio.play()


func _on_tips_timer_timeout() -> void:
	update_tips_label()


func _on_skip_loading_pressed() -> void:
	loading_progress = 100.0
