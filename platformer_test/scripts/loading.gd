extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
var game_manager
var load_duration: float = 1.5  # seconds for full bar

func run_animation() -> void:
	progress_bar.value = 0.0
	var elapsed_time := 0.0

	while elapsed_time < load_duration:
		await get_tree().process_frame  # yields until the next frame
		elapsed_time += get_process_delta_time()
		progress_bar.value = clamp(elapsed_time / load_duration, 0.0, 1.0) * 100.0

func set_game_manager(manager,filepath):
	game_manager = manager
	await run_animation()
	game_manager.next_file_path = null
	game_manager.load_level(filepath)
