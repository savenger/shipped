extends Node3D

var rnd := RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rnd.randomize()
	$destination.connect("delivered", _on_delivered)
	$destination.global_position = get_random_destination_position()

func get_random_destination_position():
	return Vector3(rnd.randi_range(0, 32), 1, rnd.randi_range(0, 32))

func _on_delivered():
	print("delivered some goods")
	$destination.global_position = get_random_destination_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
