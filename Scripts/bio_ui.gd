extends Control
class_name BioUI

signal add_coffee_requested()
signal request_caffeine_recalc()

@onready var add_coffee_button: Button = $MarginContainer/VBoxContainer/Button
@onready var caffeine_progress: ProgressBar = $MarginContainer/VBoxContainer/ProgressBar
@onready var caffeine_label: Label = $MarginContainer/VBoxContainer/Label
@onready var update_timer: Timer = $UpdateTimer

func _ready() -> void:
	add_coffee_button.pressed.connect(_on_add_coffee_button_pressed)
	update_timer.timeout.connect(func(): request_caffeine_recalc.emit())

func _on_add_coffee_button_pressed() -> void:
	add_coffee_requested.emit()

func update_caffeine_bar(current_mg: float) -> void:
	caffeine_label.text = "Cafezin no sangue: %.1f mg" % current_mg
	
	var tween = create_tween()
	tween.tween_property(caffeine_progress, "value", current_mg, 0.8)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
