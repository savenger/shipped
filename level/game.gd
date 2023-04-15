extends Node3D

var rnd := RandomNumberGenerator.new()
var last_index = 0

var base_volume : int = 0
var music_volume : int = -20

var keys = preload("res://level/Keys.tscn").instantiate()

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

func adjust_volume(base_volume):
	get_parent().get_node("AudioStreamPlayer").volume_db = music_volume + base_volume

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_released("volume_up"):
		base_volume +=  5
		adjust_volume(base_volume)
	if Input.is_action_just_released("volume_down"):
		base_volume -=  5
		adjust_volume(base_volume)

func _on_die(delivered):
	print("ship sank, you delivered %s goods" % delivered)
	get_tree().reload_current_scene()

func hide_keys():
	print("hide_keys")
	get_node("/root/Game").remove_child(keys)
