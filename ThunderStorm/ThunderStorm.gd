extends Area3D

@export var _storm_speed: float = .25

var _lightning_delay: float = 3.0
var _timer: float = 0
var _ship: Node3D = null
var _waypoint_target: Vector3 = Vector3.ZERO


func _ready():
	_waypoint_target = Vector3(randf_range(-50, 50), 15, randf_range(-50, 50))
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta):
	# Tween cloud position
	position = lerp(position, _waypoint_target, delta * _storm_speed)
	if position.distance_to(_waypoint_target) < 2:
		_waypoint_target = Vector3(randf_range(-50, 50), 15, randf_range(-50, 50))
		
	
	if !$LightningSprite.visible:
		_timer += delta
	
	if _timer > _lightning_delay:
		_timer = 0
		
		if _ship != null:
			# Random damage
			_ship.health -= randi_range(15, 30)
			print("Hit by lightning: ", _ship.health)
		
		# Show lightning
		_lightning_delay = randf_range(1, 5)
		var frame_index = randi_range(0, $LightningSprite.hframes - 1)
		$LightningSprite.frame = frame_index
		$LightningSprite.visible = true
		$OmniLight3D.visible = true
		await get_tree().create_timer(.2).timeout
		$LightningSprite.visible = false
		$OmniLight3D.visible = false


func _on_body_entered(body: Node3D):
	if body.is_in_group("ship"):
		_ship = body


func _on_body_exited(body: Node3D):
	if body.is_in_group("ship"):
		_ship = null
