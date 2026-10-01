extends Node
class_name BioTracker

signal caffeine_level_calculated(current_mg: float)

const SAVE_PATH = "user://caffeine.json"
const CAFFEINE_HALF_LIFE_SEC = 18000.0

var _doses: Array = []

func _ready() -> void:
	_load_doses()

func add_coffee(mg: float = 90.0) -> void:
	_doses.append({
		"timestamp": Time.get_unix_time_from_system(),
		"mg": mg
	})
	_save_doses()
	calculate_current_caffeine()

func calculate_current_caffeine() -> void:
	var total_mg: float = 0.0
	var current_time = Time.get_unix_time_from_system()
	var active_doses: Array = []
	
	for dose in _doses:
		var elapsed = current_time - dose["timestamp"]
		# Fórmula de decaimento exponencial: ValorAtual = ValorInicial * (0.5 ^ (TempoPassado / MeiaVida))
		var remaining_mg = dose["mg"] * pow(0.5, elapsed / CAFFEINE_HALF_LIFE_SEC)
		
		if remaining_mg > 1.0:
			total_mg += remaining_mg
			active_doses.append(dose)
			
	_doses = active_doses 
	emit_signal("caffeine_level_calculated", total_mg)

func _save_doses() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(_doses))

func _load_doses() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		if typeof(data) == TYPE_ARRAY:
			_doses = data
