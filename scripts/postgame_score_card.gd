extends PanelContainer

@export var player_id: int
@onready var stylebox : StyleBoxFlat
@onready var cont_1 := $MarginContainer/VBoxContainer/Cont1
@onready var cont_2 := $MarginContainer/VBoxContainer/Cont2
@onready var cont_3 := $MarginContainer/VBoxContainer/Cont3
@onready var cont_4 := $MarginContainer/VBoxContainer/Cont4
var final_color: Color
var player: PlayerState
var cell_counter := 0
var valid_flag_counter := 0
var invalid_flag_counter := 0
var total_counter := -1000000
var tween : Tween

const valid_flag_bonus := 5
const invalid_flag_malus := 8

func _ready() -> void:
	player = GameState.players[player_id]
	stylebox = self.get_theme_stylebox('panel').duplicate()
	final_color = player.color
	stylebox.bg_color = Color('#666666')
	stylebox.border_color = Color('#999999')
	self.add_theme_stylebox_override('panel', stylebox)
	%PlayerName.text = player.player_name
	%ValidBonus.text   = "x %d" % valid_flag_bonus
	%InvalidMalus.text = "x %d" % invalid_flag_malus
	
func reset() -> void:
	cell_counter  = 0
	valid_flag_counter = 0
	invalid_flag_counter = 0
	total_counter = 0
	cont_1.modulate.a = 0.0
	cont_2.modulate.a = 0.0
	cont_3.modulate.a = 0.0
	cont_4.modulate.a = 0.0
	
	
func update() -> void:
	tween = create_tween()
	$"../../".tween = tween # Link parent tween to this to allow skipping
	
	var valid_score   := GameState.map.count_valid_flags(player_id)
	var invalid_score := GameState.map.count_invalid_flags(player_id) 
	var final_score = player.score + valid_score*valid_flag_bonus - invalid_score*invalid_flag_malus - 1
	
	# Calculating flag scores
	tween.tween_property(stylebox, "bg_color", final_color, 0.2)
	tween.parallel().tween_property(stylebox, "border_color", final_color.lightened(0.3), 0.2)
	tween.tween_property(cont_1, "modulate:a", 1.0, 0.05)
	tween.tween_property(self, "cell_counter", player.score-1, (player.score-1)*0.05)
	tween.tween_interval(0.5)
	tween.tween_property(cont_2, "modulate:a", 1.0, 0.05)
	tween.tween_property(self, "valid_flag_counter", valid_score , valid_score*0.05)
	tween.tween_interval(0.5)
	tween.tween_property(cont_3, "modulate:a", 1.0, 0.05)
	tween.tween_property(self, "invalid_flag_counter", invalid_score, invalid_score*0.05)
	tween.tween_interval(0.5)
	tween.tween_property(cont_4, "modulate:a", 1.0, 0.05)
	tween.tween_property(self, "total_counter", final_score, final_score*0.05)
	tween.tween_interval(1.0)
	await tween.finished
	
func _process(_delta: float) -> void: 
	%RevealedCellsScore.text = str(cell_counter)
	%ValidFlagScore.text = str(valid_flag_counter)
	%InvalidFlagScore.text = str(invalid_flag_counter)
	%TotalScore.text = str(total_counter)
