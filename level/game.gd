extends Node3D

var rnd := RandomNumberGenerator.new()
var last_index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	rnd.randomize()
	$destination.connect("delivered", _on_delivered)
	$destination.position = get_random_destination_position()
	$ship.connect("die", _on_die)
	var cams: Array = CameraManager.get_cameras()
	CameraManager.set_current_camera(cams[0])

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_die(delivered):
	print("ship sank, you delivered %s goods" % delivered)
	get_tree().reload_current_scene()
