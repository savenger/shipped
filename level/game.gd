extends Node3D

var rnd := RandomNumberGenerator.new()
var last_index = 0

var base_volume : int = 0
var music_volume : int = -20

var keys = preload("res://level/Keys.tscn").instantiate()
var game_over = preload("res://level/GameOver.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready():
	rnd.randomize()
	$destination.connect("delivered", _on_delivered)
	$destination.position = get_random_destination_position()
	$ship.connect("die", _on_die)
	var cams: Array = CameraManager.get_cameras()
	CameraManager.set_current_camera(cams[0])
	add_child(keys)
	var timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", Callable(self, "hide_keys"))
	timer.one_shot = true
	timer.wait_time = 5
	timer.start()

func get_random_destination_position():
	var new_index = last_index
	while (new_index == last_index):
		new_index = rnd.randi_range(0, len($terrain.islands) - 1)
	last_index = new_index
	var island = $terrain.islands[last_index]
	return Vector3(island['x'], 1, island['z'])

func _on_delivered():
	print("delivered some goods")
	$destination.position = get_random_destination_position()

func adjust_volume(adjustment):
	print("Adjusting!")
	$AudioStreamPlayer.volume_db += adjustment
	$ship.get_node("AudioHorn").volume_db += adjustment
	$ship.get_node("AudioLightningStrike").volume_db += adjustment
	for storm in get_children():
		if storm.is_in_group("storm"):
			storm.get_node("AudioRain").volume_db += adjustment
			storm.get_node("AudioLightning").volume_db += adjustment

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_released("volume_up"):
		adjust_volume(5)
	if Input.is_action_just_released("volume_down"):
		adjust_volume(-5)

func _on_die(delivered):
	print("ship sank, you delivered %s goods" % delivered)
	game_over.get_node("Text/Score").text = ("You delivered %s goods" % str($ship.delivered))
	add_child(game_over)
	await get_tree().create_timer(10).timeout
	get_tree().reload_current_scene()

func hide_keys():
	print("hide_keys")
	get_node("/root/Game").remove_child(keys)
