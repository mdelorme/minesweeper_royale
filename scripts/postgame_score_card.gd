extends PanelContainer

@export var player_id: int
@onready var stylebox : StyleBoxFlat
@onready var cont_1 := $MarginContainer/VBoxContainer/Cont1
@onready var cont_2 := $MarginContainer/VBoxContainer/Cont2
@onready var cont_3 := $MarginContainer/VBoxContainer/Cont3
var final_color: Color
var player: PlayerState
var cell_counter := 0
var flag_counter := 0
var total_counter := 0
var tween : Tween

func _ready() -> void:
	player = GameState.players[player_id]
	stylebox = self.get_theme_stylebox('panel').duplicate()
	final_color = player.color
	stylebox.bg_color = Color('#666666')
	stylebox.border_color = Color('#999999')
	self.add_theme_stylebox_override('panel', stylebox)
	%PlayerName.text = player.player_name
	
func reset() -> void:
	cell_counter  = 0
	flag_counter  = 0
	total_counter = 0
	cont_1.modulate.a = 0.0
	cont_2.modulate.a = 0.0
	cont_3.modulate.a = 0.0
	
	
func update() -> void:
	tween = create_tween()
	$"../../".tween = tween # Link parent tween to this to allow skipping
	
	var valid_score := 0
	var invalid_score := 0
	var final_score = player.score + valid_score - invalid_score - 1
	
	# Calculating flag scores
	
	tween.tween_property(stylebox, "bg_color", final_color, 0.2)
	tween.parallel().tween_property(stylebox, "border_color", final_color.lightened(0.3), 0.2)
	tween.tween_property(cont_1, "modulate:a", 1.0, 0.05)
	tween.tween_property(self, "cell_counter", player.score-1, (player.score-1)*0.05)
	tween.tween_interval(0.5)
	tween.tween_property(cont_2, "modulate:a", 1.0, 0.05)
	tween.tween_property(self, "flag_counter", valid_score , valid_score*0.05)
	tween.tween_property(self, "flag_counter", valid_score - invalid_score, (valid_score-invalid_score)*0.05)
	tween.tween_interval(0.5)
	tween.tween_property(cont_3, "modulate:a", 1.0, 0.05)
	tween.tween_property(self, "total_counter", final_score, final_score*0.05)
	tween.tween_interval(1.0)
	await tween.finished
	
func _process(_delta: float) -> void: 
	%RevealedCellsScore.text = str(cell_counter)
	%ValidFlagScore.text = str(flag_counter)
	%TotalScore.text = str(total_counter)
