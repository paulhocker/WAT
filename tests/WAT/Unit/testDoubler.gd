extends WATTest


const d = preload("res://addons/WAT/double/refactor.gd")

func test_double_saves_script_in_WATemp() -> void:
	describe("Double.new(script) saves the doubled script in user://WATemp")

	load("res://addons/WAT/utils/filesystem.gd").clear_temporary_files()
	var expected: String = "user://WATemp/0.gd"
	var copy = d.new("res://Examples/Scripts/calcbase.gd")

	expect.file_exists(expected)

func test_double_source_code_only_extends_from_source_script():
	describe("When a script is doubled for the first time the source code only contains what it extends from")

	var copy = d.new("res://Examples/Scripts/calcbase.gd")
	var expected: String = 'extends "res://Examples/Scripts/calcbase.gd"'
	var actual = copy.double().source_code

	expect.is_equal(expected, actual)

func test_double_dummy_method_exists_in_source():
	describe("When dummy is called, it adds the dummy override to the source")

	var copy = d.new("res://Examples/Scripts/calcbase.gd")

	copy.dummy("add")
	var expected: String = "\nfunc add(a, b):\n\treturn get_meta('double').methods.add.retval"
	var actual: String = copy.double().source_code
	expect.string_contains(expected, actual)

# TESTS
# 1 FILE EXISTS
# 2 FILE BASE IS "extends source"
# 3 Dummy Method returns updated source (couple of tests here)
# 4 Instance has meta data "double"
# 5 Test Stubbed method
# 6 Static Method toggle