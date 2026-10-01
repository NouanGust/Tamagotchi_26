extends Node

@onready var repository: TaskRepository = $TaskRepository
@onready var ui: Control = $Background/AppLayout/MainUI/TaskUI
@onready var gamification: GamificationCore = $GamificationCore
@onready var bio_tracker: BioTracker = $BioTracker
@onready var bio_ui: Control = $Background/AppLayout/MainUI/BioUI 
@onready var xp_label: Label = $Background/AppLayout/TopHUD/XPLabel
@onready var coins_label: Label = $Background/AppLayout/TopHUD/CoinsLabel


func _ready() -> void:
	ui.connect("create_task_requested", Callable(repository, "add_task"))
	ui.connect("complete_task_requested", Callable(repository, "complete_task"))

	repository.connect("tasks_loaded", Callable(ui, "populate_list"))
	repository.connect("task_added", Callable(ui, "add_task_to_list"))
	
	repository.connect("task_completed", Callable(gamification, "_on_task_completed"))
	
	bio_ui.connect("add_coffee_requested", Callable(bio_tracker, "add_coffee"))
	bio_ui.request_caffeine_recalc.connect(bio_tracker.calculate_current_caffeine)
	bio_tracker.connect("caffeine_level_calculated", Callable(bio_ui, "update_caffeine_bar"))
	
	ui.delete_task_requested.connect(repository.delete_task)
	ui.postpone_task_requested.connect(repository.postpone_task)
	
	repository.tasks_changed.connect(repository.load_tasks)
	bio_tracker.calculate_current_caffeine() 
	
	gamification.stats_updated.connect(func(xp, coins):
		xp_label.text = "XP: %d" % xp
		coins_label.text = "Moedas: %d" % coins
	)
	
	repository.load_tasks()
