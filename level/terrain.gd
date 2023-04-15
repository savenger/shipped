extends Node

const COL_LAYER_MAP : int = 1
var greent_material = preload("res://assets/green.tres")

var islands : Array = []

var mapSize : int = 16
var chunkSize : int = 16
var rng := RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.seed = Time.get_ticks_msec()
	rng.randomize()
	_generateBridgeArea()
	_generateIslands()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _placeBridge(horizontal: bool, x: int, z: int, scale_factor: float, scale_factor2: float):
	var c = CSGBox3D.new()
	var scale : float= 1 - (scale_factor + scale_factor2) / 2
	var pen_size_1 = scale_factor * (mapSize * chunkSize) / 2
	var pen_size_2 = scale_factor2 * (mapSize * chunkSize) / 2
	var pen_gap = (mapSize * chunkSize) - pen_size_1 - pen_size_2
	if horizontal:
		c.position.x = x
		c.position.z = pen_size_1 - (mapSize * chunkSize) / 2 + pen_gap / 2
		c.scale.z = scale * mapSize * chunkSize
	else:
		c.position.x = pen_size_1 - (mapSize * chunkSize) / 2 + pen_gap / 2
		c.position.z = z
		c.scale.x = scale * mapSize * chunkSize
	c.position.y = 10
	$base.add_child(c)

func _placeLand(c: CSGShape3D):
	c.use_collision = true
	c.operation = CSGShape3D.OPERATION_UNION
	c.material = greent_material
	$base.add_child(c)

func _placeIsland(x: int, z: int):
	var c = CSGCylinder3D.new()
	c.position.x = x * chunkSize - (mapSize * chunkSize) / 2
	c.position.z = z * chunkSize - (mapSize * chunkSize) / 2
	c.scale.x = rng.randf_range(10.0,15.0)
	c.scale.z = rng.randf_range(10.0,15.0)
	c.scale.y = 8.0
	_placeLand(c)
	islands.append({'x': c.position.x, 'z': c.position.z})

func _generateBridgeArea():
	var horizontal : bool = (rng.randf() > 0.5)
	horizontal = false
	var bridge_pos : int = rng.randi_range(2, mapSize - 3)
	var bridge_pos2 : int = rng.randi_range(0,1)
	var scale_factor = rng.randf_range(0.8, 0.95)
	var scale_factor2 = rng.randf_range(0.8, 0.95)
	var c = CSGBox3D.new()
	var c2 = CSGBox3D.new()
	if horizontal:
		
		c.scale.x = rng.randf_range(10.0,15.0)
		c.scale.z = (chunkSize * mapSize * scale_factor) / 2
		c.scale.y = 12.0
		c.position.x = bridge_pos * chunkSize - (mapSize * chunkSize) / 2
		c.position.z = -(mapSize * chunkSize) / 2 + (c.scale.z) / 2
		_placeLand(c)
		c2.scale.x = rng.randf_range(10.0,15.0)
		c2.scale.z = (chunkSize * mapSize * scale_factor2) / 2
		c2.scale.y = 12.0
		c2.position.x = bridge_pos * chunkSize - (mapSize * chunkSize) / 2
		c2.position.z = (mapSize * chunkSize) / 2 - (c2.scale.z) / 2
		_placeLand(c2)
	else:
		c.scale.x = (chunkSize * mapSize * scale_factor) / 2
		c.scale.z = rng.randf_range(10.0,15.0)
		c.scale.y = 12.0
		c.position.x = -(mapSize * chunkSize) / 2 + (c.scale.x) / 2
		c.position.z = bridge_pos * chunkSize - (mapSize * chunkSize) / 2
		_placeLand(c)
		c2.scale.x = (chunkSize * mapSize * scale_factor2) / 2
		c2.scale.z = rng.randf_range(10.0,15.0)
		c2.scale.y = 12.0
		c2.position.x = (mapSize * chunkSize) / 2 - (c2.scale.x) / 2
		c2.position.z = bridge_pos * chunkSize - (mapSize * chunkSize) / 2
		_placeLand(c2)
	_placeBridge(horizontal, c.position.x, c.position.z, scale_factor, scale_factor2)

func _generateIslands():
	for x in range(mapSize):
		for z in range(mapSize):
			if rng.randf() > 0.95:
				_placeIsland(x, z)
				

func _generateGround():
	var noise = FastNoiseLite.new()
	noise.seed = int(Time.get_unix_time_from_system())
	#noise.period = 80
	noise.fractal_octaves = 20
	
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(mapSize * chunkSize, mapSize * chunkSize)
	plane_mesh.subdivide_depth = mapSize * chunkSize
	plane_mesh.subdivide_width = mapSize * chunkSize
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	
	var array_plane = surface_tool.commit()
	var data_tool = MeshDataTool.new()
	data_tool.create_from_surface(array_plane, 0)
	
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		vertex.y = noise.get_noise_3d(vertex.x, vertex.y, vertex.z) * 50
		data_tool.set_vertex(i, vertex)
	
	array_plane.clear_surfaces()
	
	#for i in range(array_plane.get_surface_count()):
	#	array_plane.surface_remove(i)
	
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.position.y = -20
	mesh_instance.mesh = surface_tool.commit()
	#var material = load("res://Shaders/Terrain.gdshader")
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.13, 0.25, 0.03)
	mesh_instance.set_surface_override_material(0, material)
	mesh_instance.create_trimesh_collision()
	mesh_instance.name = "terrain"
	mesh_instance.cast_shadow = false
	for child in mesh_instance.get_children():
		child.collision_layer = COL_LAYER_MAP
	
	add_child(mesh_instance)
