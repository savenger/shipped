extends StaticBody3D

signal delivered()
signal unloading(amount: float)

@export var _expected_delivery: float = 100
@export var _unload_speed: float = 0.08

@export var destination_camera: CameraViewpoint
@export var ship_camera: CameraViewpoint

var _unloaded_amount: float = 0
var _is_unloading: bool = false
var _timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _is_unloading and _unloaded_amount >= _expected_delivery:
		delivered.emit()
		_is_unloading = false
		_unloaded_amount = 0
		print("destination: delivered")
		CameraManager.set_current_camera(ship_camera)
		return
		
	_timer += delta
	if _is_unloading and _timer > _unload_speed:
		_timer = 0
		_unloaded_amount += 1
		unloading.emit(_expected_delivery - _unloaded_amount)
		print("destination: unloading ... ", _unloaded_amount)


func _on_area_3d_area_entered(_body):
	pass


func _on_area_3d_body_entered(body):
	if !body.is_in_group("ship"):
		return
	if body.cargo_amount < _expected_delivery:
		return
	CameraManager.set_current_camera(destination_camera)
	_is_unloading = true
