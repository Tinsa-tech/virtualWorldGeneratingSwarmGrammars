class_name MainMenu extends Control

@export
var evo_button : Button

@export
var saved_button : Button

@export
var sandbox_button : Button

@export
var creation_button : Button

func _ready() -> void:
	evo_button.pressed.connect(_on_evo_button_pressed)
	saved_button.pressed.connect(_on_saved_button_pressed)
	sandbox_button.pressed.connect(_on_sandbox_button_pressed)
	creation_button.pressed.connect(_on_creation_button_pressed)
	SceneManager.get_instance().current = self

func _on_evo_button_pressed():
	SceneManager.get_instance().go_to(SceneManager.Scenes.EVOLUTION)

func _on_saved_button_pressed():
	SceneManager.get_instance().go_to(SceneManager.Scenes.SAVED)

func _on_sandbox_button_pressed():
	SceneManager.get_instance().go_to(SceneManager.Scenes.SANDBOX)

func _on_creation_button_pressed():
	SceneManager.get_instance().go_to(SceneManager.Scenes.CREATION)
