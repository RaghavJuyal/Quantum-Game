extends TextEdit

@onready var label: Label = $MarginContainer/Label
var text_name = "dialogue0"
var filepath = "res://scripts/dialogue.json"
var parsedDict

func _ready() -> void:
	label.text="Text is editable"
	parsedDict = load_json(filepath)
	
func load_json(filepath: String):
	var parsedResult
	if FileAccess.file_exists(filepath):
		var dataFile = FileAccess.open(filepath, FileAccess.READ)
		parsedResult = JSON.parse_string(dataFile.get_as_text())
		#print(parsedResult["dialogue0"][0]["0"])
	else:
		#print("file not found")
		parsedResult = "No JSON"
	return parsedResult

func dialogreader(dialogname):
	var index = 0
	parsedDict[dialogname][0][String(index)]
