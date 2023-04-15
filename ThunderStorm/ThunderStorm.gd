extends Area3D


var _delay: float = 3.0
var _timer: float = 0


func _process(delta):
	if !$LightningSprite.visible:
		_timer += delta
	
	if _timer > _delay:
		_timer = 0
		_delay = randf_range(1, 5)
		var frame_index = randi_range(0, $LightningSprite.hframes - 1)
		$LightningSprite.frame = frame_index
		$LightningSprite.visible = true
		$OmniLight3D.visible = true
		await get_tree().create_timer(.2).timeout
		$LightningSprite.visible = false
		$OmniLight3D.visible = false
