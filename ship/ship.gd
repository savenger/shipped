extends RigidBody3D

var acc : float = 0.0
var rot : Vector3 = Vector3(0, 0, 0)
var rot_speed : int = 4
var thrust : float = 3.0
var brake : float = 2.0
var vel = Vector3(0, 0, 0)
var torque : int = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


@export var float_force := 1.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var water = get_node('/root/Game/terrain/Water')

@onready var probes = $ProbeContainer.get_children()

var submerged := false

func _physics_process(_delta):
	submerged = false
	for p in probes:
		var depth = water.get_height(p.global_position) - p.global_position.y 
		if depth > 0:
			submerged = true
			apply_force(Vector3.UP * float_force * gravity * depth, p.global_position - global_position)

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if submerged:
		state.linear_velocity *=  1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag 
	var rotation_direction : Vector3 = Vector3(0, 0, 0)
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
