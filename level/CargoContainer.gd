extends MeshInstance3D


@export var materials: Array[StandardMaterial3D]


func _ready():
	mesh.surface_set_material(0, materials.pick_random())

