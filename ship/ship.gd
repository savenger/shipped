extends RigidBody3D

var acc : Vector3 = Vector3(0, 0, 0)
var rot : Vector3 = Vector3(0, 0, 0)
var rot_speed : float = 2.6
var thrust : float = 40.0
var brake : float = 20.0
var vel = Vector3(0, 0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("Turn Left"):
		rot = -global_transform.basis.y * rot_speed
	else:
		rot = Vector3(0, 0, 0)
	if Input.is_action_pressed("Turn Right"):
		#rot += delta * rot_speed
		rot = global_transform.basis.y * rot_speed
	else:
		rot = Vector3(0, 0, 0)
		
	if Input.is_action_pressed("Thrust"):
		acc = Vector3(thrust, 0, 0) #.rotated(Vector3.UP, rot)
	else:
		acc = Vector3(0, 0, 0)
	if Input.is_action_pressed("CounterThrust"):
		acc = Vector3(-brake, 0, 0) #.rotated(Vector3.UP, rot)
	vel += acc * delta
	#position += vel * delta
	#$RigidBody3D.apply_torque(rot)
	#$RigidBody3D.apply_force(vel)
	#$RigidBody3D.angular_velocity = -basis.y * rot_speed


@export var float_force := 1.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var water = get_node('/root/Game/terrain/Water')

@onready var probes = $ProbeContainer.get_children()

var submerged := false

func _physics_process(delta):
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
