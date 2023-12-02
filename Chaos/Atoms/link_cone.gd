class_name AtomLinkCone extends Node2D

@export_color_no_alpha var color: Color

var atom: Atom

var _destroy_time: float = 0
var _is_destroyed: bool = false

func _process(delta: float):
	if _is_destroyed:
		_destroy_time += delta
		if _destroy_time > 1: queue_free()
	else:
		var dist := atom.global_position - global_position
		var size := dist.length() / 64.0
		var n_dist := dist.normalized()
		scale = Vector2(size, 1.0)
		rotation = atan2(n_dist.y, n_dist.x)
		modulate = color

func get_link() -> AtomLinker:
	return get_parent() as AtomLinker

func change_parent(link: AtomLinker):
	if get_parent() == null: link.add_child(self)
	else: reparent(link)
	atom.link = link

func destroy():
	atom.link = null
	reparent(atom.get_parent())
	_is_destroyed = true
