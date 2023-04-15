extends Node3D

signal delivered()

@export var _expected_delivery: float = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_area_3d_area_entered(_body):
	pass


func _on_area_3d_body_entered(body):
	if !body.is_in_group("ship"):
		return
	if body.cargo_amount < _expected_delivery:
		return
	delivered.emit()
