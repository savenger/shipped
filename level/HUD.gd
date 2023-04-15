extends CanvasLayer

func ready():
	$TimerShowGameOver.connect("timeout", Callable(self, "_on_TimerShowGameOver_timeout").bind(Globals.game_is_over))

func start_over():
	$GameOver.visible = false
	$StartOver.visible = false

func show_game_over_label():
	print("show_game_over_label")
	$TimerShowGameOver.start()

func _on_TimerShowGameOver_timeout():
	print("show_game_over_label - for real i guess.... " + str(Globals.game_is_over))
	if $GameOver.visible and Globals.game_is_over:
		$StartOver.visible = Globals.game_is_over
	$GameOver.visible = Globals.game_is_over
	if Globals.game_is_over and not $StartOver.visible:
		$TimerShowGameOver.start()
