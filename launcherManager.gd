extends Control

@onready var infos_label: Label = $infosLabel

func _ready() -> void:
	get_tree().set_quit_on_go_back(false)
	
	infos_label.text = ""
	

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		infos_label.text = "Não tem volta!"
