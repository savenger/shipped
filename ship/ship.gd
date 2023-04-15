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
		$AudioStreamPlayer2D.play()
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


func _on_ship_loading(_cargo_port: CargoPort, progress: float):
	if cargo_amount >= cargo_capacity:
		print("Ship at max capcity")
	else:
		# Loading ship
		cargo_amount += progress
		

func _on_delivered():
	# Reset cargo amount
	cargo_amount = 0
	delivered += 1
	print("Reset cargo amount")


func _on_body_entered(_body):
	if linear_velocity.length() > 3:
		health -= int(linear_velocity.length())
	print(health)
	$SpotLightAlert.visible = (health < 50.0)
	$SpotLightAlert2.visible = (health < 50.0)
	if health < 50.0:
		if thrust == MAX_THRUST:
			thrust = MAX_THRUST / 2.0
			brake = MAX_BRAKE / 2.0
		if health <= 0.0 and not dead:
			dead = true
			$CollisionShape3D.visible = false
			$AnimationPlayerDeath.play("death")
			emit_signal("die", delivered)
