class_name AtomLinker extends Node2D

signal destroyed(link: AtomLinker)

@export var dist_mod: float
@export var break_mod: float

var _cone_scene: PackedScene = preload("res://Chaos/Atoms/link_cone.tscn")

var _velocity: Vector2
var _rot: float
var _merge_velocity: Vector2
var _merge_multiplier: float = 1.0
var _merge_count: int = 0

func _ready():
	_rot = PI / 128 * (1 if randf() < 0.5 else -1)

func _process(_delta: float):
	var max_dist := 128.0 + _full_atom_count() * 48 * break_mod

	var remove_list: Array[Atom] = []
	for child in get_children():
		var cone := child as AtomLinkCone
		var atom := cone.atom
		if (atom.position - position).length() > max_dist:
			remove_list.append(atom)
	for item in remove_list:
		remove_atom(item)

	if get_child_count() <= 1:
		destroy()

func _physics_process(delta: float):
	var min_target := 64.0 + _full_atom_count() * 12 * dist_mod
	var max_target := 64.0 + _full_atom_count() * 20 * dist_mod
	var vel := _velocity

	for item in get_children():
		var cone := item as AtomLinkCone
		var atom := cone.atom
		var diff := atom.position - position
		var dist := diff.length()
		var move: float = _calc_base_difference(min_target, max_target, dist)
		var n_dir := diff.normalized()
		var dist_vel := n_dir * move
		var rot_vel := n_dir.rotated(PI / 2) * (_rot * atom_count())
		atom.linear_velocity += dist_vel + rot_vel
		vel -= dist_vel / atom_count()
	_velocity = (vel + _merge_velocity) * _merge_multiplier
	position += _velocity * delta

func atom_count() -> int:
	return get_child_count()

func destroy():
	for child in get_children():
		(child as AtomLinkCone).destroy()
	destroyed.emit(self)
	queue_free()

func add_atoms(atoms: Array[Atom]):
	for atom in atoms:
		_create_link(atom)

func remove_atom(atom: Atom):
	for child in get_children():
		var cone := child as AtomLinkCone
		if cone.atom == atom:
			cone.destroy()
			return

func contains_atom(atom: Atom) -> bool:
	for child in get_children():
		if child is AtomLinkCone:
			if (child as AtomLinkCone).atom == atom: return true
	return false

func set_merge(vel: Vector2, count: int = 0, mult: float = 1.0):
	_merge_velocity = vel
	_merge_count = count
	_merge_multiplier = mult

func _calc_base_difference(min_target: float, max_target: float, dist: float) -> float:
	var d: float = 0
	if dist < min_target: d = min_target - dist
	elif dist > max_target: d = max_target - dist
	return sqrt(absf(d)) * signf(d)

func _create_link(atom: Atom):
	if contains_atom(atom): return
	elif atom.link != null: atom.link.remove_atom(atom)
	var cone := _cone_scene.instantiate() as AtomLinkCone
	cone.atom = atom
	cone.color = atom.get_color()
	cone.change_parent(self)

func _full_atom_count() -> int:
	return _merge_count if _merge_count != 0 else get_child_count()
