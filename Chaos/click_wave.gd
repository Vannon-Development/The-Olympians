extends Node2D

@export var time: float
@export var size: float
@export var max_force: float
@onready var effect: Node2D = $"effect area" as Node2D
@onready var collider: CollisionShape2D = $"effect area/collider" as CollisionShape2D

var _timer: float

func _ready():
	effect.scale = Vector2(0.1, 0.1)
	_timer = 0
	var h := randf()
	var s := randf_range(0.3, 0.8)
	var v := randf_range(0.6, 1)
	modulate = Color.from_hsv(h, s, v)

func _process(delta: float):
	_timer += delta
	var n_time := clampf(_timer / time, 0, 1)
	var n_size := lerpf(0.1, size, n_time)
	effect.scale = Vector2(n_size, n_size)
	if _timer > time: queue_free()

func _hit_atom(body: Node2D):
	if not body is Atom: return
	var dir := body.position - position
	if dir.is_zero_approx():
		var angle := randf_range(0, 2 * PI)
		dir = Vector2(cos(angle), sin(angle))
	dir = dir.normalized()
	var force := lerpf(max_force, 0, clampf(_timer / time, 0, 1))
	var b := body as RigidBody2D
	b.linear_velocity += dir * force
