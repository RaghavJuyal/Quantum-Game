extends Control

var target_scene_path

var loading_status : int
var progress : Array[float]
#@onready var game_manager: Node = get_tree().root.get_node("Game/GameManager")
var game_manager = get_tree().root.get_node("res://scenes/game.tscn")

@onready var progress_bar : ProgressBar = $ProgressBar
var loading = false

func _ready() -> void:
	pass
	# Request to load the target scene:
	#ResourceLoader.load_threaded_request(target_scene_path)
	
func manager_loader() -> void:
	print(target_scene_path)
	game_manager.load_level(target_scene_path)
	
func _process(_delta: float) -> void:
	if !loading:
		loading = true
		manager_loader()
	## Update the status:
	#loading_status = ResourceLoader.load_threaded_get_status(target_scene_path, progress)
	#
	## Check the loading status:
	#match loading_status:
		#ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			#progress_bar.value = progress[0] * 100 # Change the ProgressBar value
		#ResourceLoader.THREAD_LOAD_LOADED:
			## When done loading, change to the target scene:
			#get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(target_scene_path))
		#ResourceLoader.THREAD_LOAD_FAILED:
			## Well some error happend:
			#print("Error. Could not load Resource")
