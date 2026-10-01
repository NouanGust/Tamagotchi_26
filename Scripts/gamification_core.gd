extends Node
class_name GamificationCore

signal stats_updated(xp: int, coins: int)

const SAVE_PATH = "user://stats.json"
var current_xp: int = 0
var current_coins: int = 0

func _ready() -> void:
	_load_stats()

func _on_task_completed(task: Dictionary, is_combo_payout: bool = false) -> void:
	var base_xp = 10
	var base_coins = 5
	var penalty = task.get("postpone_count", 0)
	var final_xp = max(1, base_xp - (penalty * 2))
	var final_coins = max(0, base_coins - penalty)
	
	if is_combo_payout:
		var target = task.get("combo_target", 4)
		final_xp = (final_xp * target) + 20
		final_coins = (final_coins * target) + 15
		
	current_xp += final_xp
	current_coins += final_coins
	_save_stats()
	emit_signal("stats_updated", current_xp, current_coins)

func _load_stats() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		if typeof(data) == TYPE_DICTIONARY:
			current_xp = data.get("xp", 0)
			current_coins = data.get("coins", 0)
	emit_signal("stats_updated", current_xp, current_coins)

func _save_stats() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify({"xp": current_xp, "coins": current_coins}))
