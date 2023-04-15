extends Area3D


var _delay: float = 3.0
var _timer: float = 0
var _is_inside_storm: bool = false
var _ship: Node3D = null


func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta):
	if !$LightningSprite.visible:
		_timer += delta
	
	if _timer > _delay:
		if _ship != null:
			_ship.health -= randi_range(15, 30)
			print("Hit by lightning: ", _ship.health)
		_timer = 0
		_delay = randf_range(1, 5)
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
