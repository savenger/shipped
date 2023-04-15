extends Node3D

@export var _containers: Array[PackedScene]
@export var _spacing: Vector3 = Vector3(1.5, 0, 0.70)
@export var _offset: Vector3 = Vector3(0, 0, 1.4)

@onready var _ship = get_parent()

var _container_total: float = 0

func _ready():
	_container_total = len(get_children())


func _process(_delta):
	for child in get_children():
		var container_index_percentage = Utils.remap_range(float(child.get_index()), 0, _container_total, 0, 100)
#		print (_ship.cargo_amount, " --- ", container_index_percentage )
		child.visible = _ship.cargo_amount > container_index_percentage 


func spawn_container():
	var container_scene = _containers.pick_random()
	var container = container_scene.instantiate() as Node3D
	add_child.call_deferred(container)
	return container
