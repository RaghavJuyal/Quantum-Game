extends TextEdit

@onready var label: Label = $MarginContainer/Label
var text_name = "dialogue0"
var filepath = "res://scripts/dialogue.json"
var parsedResult

func _ready() -> void:
	label.text = "Text is editable"
	load_json(filepath)
	
func load_json(filepath: String) -> void:
	if FileAccess.file_exists(filepath):
		var dataFile = FileAccess.open(filepath, FileAccess.READ)
		parsedResult = JSON.parse_string(dataFile.get_as_text())
		print(parsedResult["dialogue1"])
		#print(type_string(typeof(parsedResult["dialogue0"][0]["0"])))
	else:
		#print("file not found")
		parsedResult = "No JSON"

func dialogreader(dialogname, index) -> void:
	#print(type_string(typeof(parsedResult["dialogue0"][0]["0"])))
	#print(index)
	#continue editing this accordingly plz
	#print(type_string(typeof(label.text)))
	label.text = parsedResult[dialogname][index][str(index)]
	#label.text = "Fuck this"
