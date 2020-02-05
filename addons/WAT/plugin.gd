tool
extends EditorPlugin

const TITLE: String = "Tests"
const RUN_CURRENT_SCENE_GODOT_3_2: int = 39
const RUN_CURRENT_SCENE_GODOT_3_1: int = 33
const UI: PackedScene = preload("res://addons/WAT/Wat.tscn")
var interface: PanelContainer

func _enter_tree() -> void:
	_set_tags()
	_create_test_folder()
	_create_temp_folder()
	interface = UI.instance()
	interface.connect("test_runner_started", self, "_on_test_runner_started")
	interface.connect("results_displayed", self, "make_bottom_panel_item_visible", [interface])
	add_control_to_bottom_panel(interface, "Tests")
	ProjectSettings.set_setting("WAT/Goto_Test_Method", funcref(self, "goto_function"))
	
func _set_tags() -> void:
	if ProjectSettings.has_setting("WAT/Tags"):
		return
	var tags: PoolStringArray = []
	var property_info: Dictionary = {
		"name": "WAT/Tags",
		"type": TYPE_STRING_ARRAY,
		"hint_string": "Defines Tags to group Tests"
	}
	ProjectSettings.set("WAT/Tags", tags)
	ProjectSettings.add_property_info(property_info)
	
	
func goto_function(path: String, function: String) -> void:
	var script: Script = load(path)
	get_editor_interface().edit_resource(script)
	var source: PoolStringArray = script.source_code.split("\n")
	for i in source.size():
		if function in source[i] and "describe" in source[i]:
			get_editor_interface().get_script_editor().goto_line(i)
			return

func _exit_tree() -> void:
	remove_control_from_bottom_panel(interface)
	interface.free()

func get_plugin_name() -> String:
   return "WAT"

func _create_temp_folder() -> void:
	Directory.new().make_dir("user://WATemp")

func _create_test_folder() -> void:
	var title: String = "WAT/Test_Directory"
	if not ProjectSettings.has_setting(title):
		var property_info: Dictionary = {"name": title, "type": TYPE_STRING, "hint_string": "Store your WATTests here"}
		ProjectSettings.set(title, "res://tests")
		ProjectSettings.add_property_info(property_info)
		push_warning("Set Test Directory to 'res://tests'. You can change this in Project -> Project Settings -> General -> WAT")
		return

func _on_test_runner_started(test_runner_path: String) -> void:
	print(test_runner_path)
	get_editor_interface().open_scene_from_path(test_runner_path)
	var version = Engine.get_version_info()
	if version.major == 3 and version.minor == 1:
		get_editor_interface().get_parent()._menu_option(RUN_CURRENT_SCENE_GODOT_3_1)
	elif version.major == 3 and version.minor == 2:
		get_editor_interface().get_parent()._menu_option(RUN_CURRENT_SCENE_GODOT_3_2)
		
