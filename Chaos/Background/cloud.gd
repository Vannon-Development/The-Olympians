class_name BGCloud extends Node2D

@export var min_speed: float
@export var max_speed: float

@onready var visual: Sprite2D = $"Visual"

var motion: Vector2

func _ready():
	visual.frame = randi_range(0, 15)

func _process(delta: float):
	position += motion * delta

func _on_frame_exit():
	queue_free()
