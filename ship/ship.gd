extends RigidBody3D

signal die()

const MAX_HEALTH : int = 100
const MAX_THRUST: float = 1.5
const MAX_BRAKE: float = 0.5
var health : int = MAX_HEALTH
var acc : float = 0.0
var rot : Vector3 = Vector3(0, 0, 0)
var rot_speed : int = 4
var thrust : float = MAX_THRUST
var brake : float = MAX_BRAKE
var vel = Vector3(0, 0, 0)
var torque : int = 200
var delivered : int = 0
var dead: bool = false

@export var strike_force := 5000.0

@export_category("Cargo")
# Whether the ship has cargo or not ...
var cargo_amount: float = 0
@export var cargo_capacity = 100
@export var destination: Node

@export_category("Buoyancy")
@export var float_force := 1.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var water = get_node('/root/Game/terrain/Water')

@onready var probes = $ProbeContainer.get_children()

var submerged := false

func _ready() -> void:
	destination.delivered.connect(_on_delivered)
	var cargo_ports = get_tree().get_nodes_in_group("cargo_port")
	var destination_port = get_tree().get_nodes_in_group("destination_port")[0]
	destination_port.unloading.connect(_on_unloading)
	for port in cargo_ports:
		port.ship_loading.connect(_on_ship_loading)

func _process(_delta):
	pass

func _physics_process(_delta):
	if health <= 0.0:
		return
	submerged = false
	for p in probes:
		var depth = water.get_height(p.global_position) - p.global_position.y 
		if depth > 0:
			submerged = true
			apply_force(Vector3.UP * float_force * gravity * depth, p.global_position - global_position)

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if health <= 0.0:
		return
	if submerged:
		state.linear_velocity *=  1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag 
	var rotation_direction : Vector3 = Vector3(0, 0, 0)
	if Input.is_action_just_pressed("horn"):
		if !$AudioHorn.playing:
			$AudioHorn.play()
	if Input.is_action_pressed("Turn Right"):
		rotation_direction.y -= rot_speed
	if Input.is_action_pressed("Turn Left"):
		rotation_direction.y += rot_speed
	if Input.is_action_pressed("Thrust"):
		acc = thrust
	else:
		acc = 0
	if Input.is_action_pressed("CounterThrust"):
		acc = -brake
		pass
	state.apply_torque(rotation_direction * torque)
	state.apply_force(($front.global_position - global_position) * 100 * acc)
	$AudioEngine.pitch_scale = clamp(0.4 + linear_velocity.length() / 15, 0.8, 1)
func start_loading_sound():
	if !$AudioLoading.playing:
		if !$AudioLoadingBegin.playing:
			$AudioLoadingBegin.play()

func stop_loading_sound():
	if $AudioLoading.playing or $AudioLoadingBegin.playing:
		$AudioLoadingBegin.stop()
		$AudioLoading.stop()
		if !$AudioLoadingEnd.playing:
			$AudioLoadingEnd.play()

func _on_ship_loading(_cargo_port: CargoPort, progress: float):
	if cargo_amount >= cargo_capacity:
		print("Ship at max capcity")
	else:
		start_loading_sound()
		# Loading ship
		cargo_amount = progress
		if cargo_amount == 100:
			print("full cargo!!!")
			stop_loading_sound()


func _on_unloading(progress: float):
	if cargo_amount == 100:
		start_loading_sound()
	if progress <= 0:
		return
	print("do unload")
	cargo_amount = progress


func _on_delivered():
	# Reset cargo amount
	cargo_amount = 0
	health += 30
	health = max(100, health)
	check_alert_mode()
	delivered += 60
	if $AudioLoading.playing:
		$AudioLoading.stop()
	$AudioLoadingEnd.play()
	print("Reset cargo amount")

func struck_by_lightning():
	apply_force(Vector3.DOWN * strike_force, $top.position)
	$AudioLightningStrike.play()

func check_alert_mode():
	$SpotLightAlert.visible = (health < 50.0)
	$SpotLightAlert2.visible = (health < 50.0)
	if health < 50.0:
		thrust = MAX_THRUST / 2.0
		brake = MAX_BRAKE / 2.0
	else:
		thrust = MAX_THRUST
		brake = MAX_BRAKE

func _on_body_entered(_body):
	if linear_velocity.length() > 3:
		health -= int(linear_velocity.length())
		$AudioCollision.play()
	print(health)
	check_alert_mode()
	if health <= 0.0 and not dead:
		dead = true
		$CollisionShape3D.visible = false
		$AnimationPlayerDeath.play("death")
		emit_signal("die", delivered)


func _on_audio_loading_begin_finished():
	$AudioLoading.play()
