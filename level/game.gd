extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$destination.connect("delivered", _on_delivered)

func _on_delivered():
	print("delivered some goods")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
