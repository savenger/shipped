extends Node

const COL_LAYER_MAP : int = 1

var mapSize : int = 32
var chunkSize : int = 16

# Called when the node enters the scene tree for the first time.
func _ready():
	#_generateCSGGround()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _generateCSGGround():
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
		#vertex.y = noise.get_noise_3d(vertex.x, vertex.y, vertex.z) * 50
		vertex.y = 25
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
