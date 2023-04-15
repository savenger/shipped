extends Area3D

@onready var _parent: CargoPort = get_parent()

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

	# Loading ship
	_timer += delta
	var load_percentage = remap_range(_timer, 0, 10, 0, 100)
	print("Loading ship: %s" % round(load_percentage))
		
	if _timer >= _parent.duration:
		# Finished loading
		_loading_state = LOADED_SHIP
		_parent.ship_loaded.emit()
		print("Ship Loaded!")


func _on_body_entered(body: Node3D) -> void:
	if !body.is_in_group("ship"):
		return
	_loading_state = LOADING_SHIP


func _on_body_exited(body: Node3D) -> void:
	if !body.is_in_group("ship"):
		return
	if _loading_state != LOADED_SHIP:
		_loading_state = AWAITING_SHIP


func remap_range(value, in_min, in_max, out_min, out_max):
	return(value - in_min) / (in_max - in_min) * (out_max - out_min) + out_min
