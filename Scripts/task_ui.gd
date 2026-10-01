extends Control
class_name TaskUI

signal create_task_requested(title: String, deadline_sec: int)
signal complete_task_requested(task_id: String)
signal delete_task_requested(task_id: String)
signal postpone_task_requested(task_id: String)

@export var task_item_scene: PackedScene

@onready var task_line_edit: LineEdit = $SafeAreaMargin/MainVBox/InputHBox/TaskLineEdit
@onready var deadline_option: OptionButton = $SafeAreaMargin/MainVBox/InputHBox/OptionButton
@onready var add_button: Button = $SafeAreaMargin/MainVBox/InputHBox/AddButton
@onready var task_list: VBoxContainer = $SafeAreaMargin/MainVBox/ScrollContainer/TaskList

var tick_timer: Timer

func _ready() -> void:
	_setup_deadline_options()
	_setup_tick_timer()
	
	add_button.pressed.connect(_on_add_button_pressed)
	task_line_edit.text_submitted.connect(func(_text): _on_add_button_pressed()) 

func _setup_deadline_options() -> void:
	deadline_option.clear()
	deadline_option.add_item("1 Hora", 3600)
	deadline_option.add_item("12 Horas", 43200)
	deadline_option.add_item("24 Horas", 86400)
	deadline_option.select(2) # Deixa "24 Horas" como padrão

func _setup_tick_timer() -> void:
	tick_timer = Timer.new()
	tick_timer.wait_time = 60.0 
	tick_timer.autostart = true
	add_child(tick_timer)
	
	tick_timer.timeout.connect(func():
		for item in task_list.get_children():
			if item.has_method("update_status"):
				item.update_status()
	)

func _on_add_button_pressed() -> void:
	var title = task_line_edit.text.strip_edges()
	if title.is_empty():
		return
	
	var selected_id = deadline_option.get_item_id(deadline_option.selected)
	
	create_task_requested.emit(title, selected_id)
	task_line_edit.text = ""
	task_line_edit.release_focus()

func populate_list(tasks: Array) -> void:
	for child in task_list.get_children():
		child.queue_free()
	for task in tasks:
		add_task_to_list(task)

func add_task_to_list(task_data: Dictionary) -> void:
	var item: TaskItem = task_item_scene.instantiate()
	task_list.add_child(item)
	item.setup(task_data)
	
	item.task_completed.connect(func(id): complete_task_requested.emit(id))
	item.delete_requested.connect(func(id): delete_task_requested.emit(id))
	item.postpone_requested.connect(func(id): postpone_task_requested.emit(id))
	
	
