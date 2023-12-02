@tool
class_name Atom extends RigidBody2D

signal on_link(atom1: Atom, atom2: Atom)

enum AtomType { Air, Earth, Water, Fire, Light, Dark }

@export var type: AtomType
@export_group("Colors")
@export_color_no_alpha var air_color: Color
@export_color_no_alpha var earth_color: Color
@export_color_no_alpha var water_color: Color
@export_color_no_alpha var fire_color: Color
@export_color_no_alpha var light_color: Color
@export_color_no_alpha var dark_color: Color

@onready var _visual: Sprite2D = $"Visual" as Sprite2D
@onready var _colors: Array[Color] = [air_color, earth_color, water_color, fire_color, light_color, dark_color]

var link: AtomLinker = null

func _ready():
	if not Engine.is_editor_hint():
		_visual.modulate = _colors[int(type)]
		var angle := randf_range(0, 2 * PI)
		var speed := randf_range(0, 10)
		linear_velocity = Vector2(cos(angle), sin(angle)) * speed

func _process(_delta: float):
	if Engine.is_editor_hint(): _visual.modulate = _colors[int(type)]

func get_color() -> Color:
	return _colors[int(type)]

func _atom_collide(body: Node):
	if Engine.is_editor_hint(): return
	if body is Atom:
		var atom := body as Atom
		if atom.type == type and (link == null or link != atom.link ):
			on_link.emit(self, atom)
