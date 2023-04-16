extends Area3D

@onready var _parent: CargoPort = get_parent()

var _docked_ship: Node3D = null
var _timer: float = 0.0
var _loaded_amount: float = 0.0
var _loading_state: int = 0
enum {
	AWAITING_SHIP,
	LOADING_SHIP,
	LOADED_SHIP
}


func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float):
	if _loading_state != LOADING_SHIP:
		return

	if _docked_ship == null:
		return
	
	if _docked_ship.cargo_amount >= _docked_ship.cargo_capacity:
		return

	_timer += delta
		
	if _timer >= _parent.loading_speed:
		_timer = 0
		# Loading ship
		_loaded_amount += 1
		_parent.ship_loading.emit(_parent, _loaded_amount)
		print("loading ", _loaded_amount)
		
		if _docked_ship.cargo_amount >= _docked_ship.cargo_capacity:
			# Finished loading
			_loading_state = LOADED_SHIP
			_parent.ship_loaded.emit(_parent)
			_loaded_amount = 0
			print("Ship Loaded!")


func _on_body_entered(body: Node3D) -> void:
	if !body.is_in_group("ship"):
		return
	_loading_state = LOADING_SHIP
	_docked_ship = body
	CameraManager.set_current_camera(_parent.cargo_camera)


func _on_body_exited(body: Node3D) -> void:
	if !body.is_in_group("ship"):
		return
	if _loading_state != LOADED_SHIP:
		_loading_state = AWAITING_SHIP
	_docked_ship = null
	CameraManager.set_current_camera(_parent.ship_camera)
