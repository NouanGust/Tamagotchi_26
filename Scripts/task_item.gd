extends PanelContainer
class_name TaskItem

# Sinais existentes...
signal task_completed(id: String)
signal delete_requested(id: String)
signal postpone_requested(id: String)

var _task_id: String = ""
var _deadline: float = 0.0
var _postpone_count: int = 0
var _is_completed: bool = false

# Cores hexadecimais para Dark Mode (suaves para não cegar o usuário)
const COLOR_GREEN = Color("2d4a22")
const COLOR_YELLOW = Color("6b5b1c")
const COLOR_RED = Color("5c201e")
const COLOR_PURPLE = Color("432a59")
const COLOR_DONE = Color("222222") # Cinza escuro para finalizadas

@onready var title_label: Label = $MarginContainer/HBoxContainer/TitleLabel
@onready var complete_button: Button = $MarginContainer/HBoxContainer/CompleteButton
@onready var delete_button: Button = $MarginContainer/HBoxContainer/DeleteButton
@onready var postpone_button: Button = $MarginContainer/HBoxContainer/PostponeButton

# Armazena o estilo único deste item
var _custom_style: StyleBoxFlat

func _ready() -> void:
	# Configurações de botões e vibração que já fizemos...
	complete_button.pressed.connect(_on_complete_button_pressed)
	delete_button.pressed.connect(func():
		Input.vibrate_handheld(100)
		delete_requested.emit(_task_id)
	)
	postpone_button.pressed.connect(func():
		Input.vibrate_handheld(30)
		postpone_requested.emit(_task_id)
	)
	
	# Cria um estilo único copiando o padrão do Theme para podermos pintar
	_custom_style = get_theme_stylebox("panel").duplicate()
	add_theme_stylebox_override("panel", _custom_style)

func setup(task_data: Dictionary) -> void:
	_task_id = task_data["id"]
	title_label.text = task_data["title"]
	_deadline = task_data.get("deadline", 0.0)
	_postpone_count = task_data.get("postpone_count", 0)
	_is_completed = task_data["completed"]
	
	if _is_completed:
		_mark_as_done(true)
	else:
		update_status() # Calcula a cor inicial

# É chamada pelo setup e pelo Timer da TaskUI a cada minuto
func update_status() -> void:
	if _is_completed: return
	
	var current_time = Time.get_unix_time_from_system()
	var time_left = _deadline - current_time
	var target_color = COLOR_GREEN
	
	if time_left <= 0:
		target_color = COLOR_RED
	elif time_left <= 7200: # 7200 segundos = 2 horas
		target_color = COLOR_YELLOW
	elif _postpone_count > 0:
		target_color = COLOR_PURPLE
		
	# Anima a transição da cor
	var tween = create_tween()
	tween.tween_property(_custom_style, "bg_color", target_color, 0.5)

func _on_complete_button_pressed() -> void:
	Input.vibrate_handheld(50)
	emit_signal("task_completed", _task_id)
	_is_completed = true
	_mark_as_done(false)

func _mark_as_done(instant: bool = false) -> void:
	complete_button.disabled = true
	postpone_button.disabled = true
	
	var tween = create_tween().set_parallel(true)
	var time = 0.0 if instant else 0.4
	
	tween.tween_property(self, "modulate", Color(0.5, 0.5, 0.5, 0.7), time)
	tween.tween_property(_custom_style, "bg_color", COLOR_DONE, time)
	
	if not instant:
		complete_button.pivot_offset = complete_button.size / 2
		tween.tween_property(complete_button, "scale", Vector2(0.8, 0.8), 0.3).set_trans(Tween.TRANS_BACK)
