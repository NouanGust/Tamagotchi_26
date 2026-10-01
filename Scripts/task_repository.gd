extends Node
class_name TaskRepository

signal tasks_loaded(tasks: Array)
signal task_added(task: Dictionary)
signal task_completed(task_id: Dictionary, is_combo_payout: bool)
signal tasks_changed()

const SAVE_PATH = "user://tasks.json"
var _tasks: Array = []


func load_tasks() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		emit_signal("tasks_loaded", [])
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	if json.parse(content) == OK:
		_tasks = json.data
		emit_signal("tasks_loaded", _tasks)
	
	check_failed_combo()


func save_tasks() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(_tasks))

func add_task(title: String, deadline_sec: int, is_recurring: bool = false , use_combo: bool = false) -> void:
	var new_task = {
		"id": str(Time.get_unix_time_from_system()),
		"title": title,
		"completed": false,
		"deadline": Time.get_unix_time_from_system() + deadline_sec,
		"postpone_count": 0,
		"recurring": is_recurring,
		"combo_enabled": use_combo,
		"combo_target": 4,
		"current_combo": 0
	}
	_tasks.append(new_task)
	save_tasks()
	task_added.emit(new_task)


func complete_task(task_id: String) -> void:
	for task in _tasks:
		if task["id"] == task_id and not task["completed"]:
			var is_payout = false
			
			if task.get("combo_enabled", false):
				task["current_combo"] += 1
				if task["current_combo"] >= task.get("combo_target", 4):
					is_payout = true
					task["current_combo"] = 0
			else:
				is_payout = true
				
			if is_payout:
				task_completed.emit(task, task.get("combo_enabled", false))
			
			if task.get("recurring", false):
				task["deadline"] = Time.get_unix_time_from_system() + 86400 
				task["postpone_count"] = 0
			else:
				task["completed"] = true
				
			save_tasks()
			tasks_changed.emit()
			break

func delete_task(task_id: String) -> void:
	for i in range(_tasks.size()):
		if _tasks[i]["id"] == task_id:
			_tasks.remove_at(i)
			save_tasks()
			tasks_changed.emit()
			break
		

func postpone_task(task_id: String, extra_time_sec: int = 86400) -> void:
	for task in _tasks:
		if task["id"] == task_id:
			task["deadline"] += extra_time_sec
			task["postpone_count"] += 1
			save_tasks()
			tasks_changed.emit()
			break
	

func check_failed_combo() -> void:
	var current_time = Time.get_unix_time_from_system()
	var changed = false
	
	for task in _tasks:
		if not task["completed"] and current_time > task["deadline"]:
			if task.get('combo_enabled', false) and task.get("current_combo", 0) > 0 :
				task["current_combo"] = 0
				changed = true
	
	if changed:
		save_tasks()
		tasks_changed.emit()
