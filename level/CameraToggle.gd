extends Node


var _cameras: Array[Node]
var _index = 0


func _ready() -> void:
	_cameras = CameraManager.get_cameras()

func _unhandled_input(event):
	if (event is InputEventJoypadButton and event.button_index == JOY_BUTTON_RIGHT_SHOULDER and event.pressed) or (event is InputEventKey and event.keycode == KEY_C and event.pressed):
		if _index + 1 >= len(_cameras):
			_index = 0
		else:	
			_index += 1
		if _cameras[_index] is CameraViewpoint:
			CameraManager.set_current_camera(_cameras[_index])
		
