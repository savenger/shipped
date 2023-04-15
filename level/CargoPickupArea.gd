extends Area3D

@onready var _parent: CargoPort = get_parent()

var _docked_ship: Node3D = null
var _timer: float = 0
var _loading_state: int = 0
enum {
	AWAITING_SHIP,
	LOADING_SHIP,
	LOADED_SHIP
}


func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta):
	if _loading_state != LOADING_SHIP:
		return

	if _docked_ship == null:
		return
	
	if _docked_ship.cargo_amount >= _docked_ship.cargo_capacity:
		return

	# Loading ship
	_timer += delta
	var load_percentage: float = (_parent.duration / _docked_ship.cargo_capacity) * 100
	_parent.ship_loading.emit(_parent, load_percentage)
	print("Loading ship: %s" % round(load_percentage))
		
	if _timer >= _parent.duration:
		# Finished loading
		_loading_state = LOADED_SHIP
		_parent.ship_loaded.emit(_parent)
		print("Ship Loaded!")


func _on_body_entered(body: Node3D) -> void:
	if !body.is_in_group("ship"):
		return
	_loading_state = LOADING_SHIP
	_docked_ship = body


func _on_body_exited(body: Node3D) -> void:
	if !body.is_in_group("ship"):
		return
	if _loading_state != LOADED_SHIP:
		_loading_state = AWAITING_SHIP
	_docked_ship = null
