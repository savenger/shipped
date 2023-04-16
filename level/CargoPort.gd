extends StaticBody3D

class_name CargoPort

signal ship_loaded(cargo_port: CargoPort)
signal ship_loading(cargo_port: CargoPort, progress: float)

@export var loading_speed: float = 1.0

