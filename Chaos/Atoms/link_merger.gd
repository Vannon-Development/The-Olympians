class_name LinkMerger extends Node2D

@export var center: float
@export var merge_speed: float

var _link_scene = preload("res://Chaos/Atoms/atom_linker.tscn")

var _links: Array[AtomLinker]

func _process(_delta: float):
	_merge_centered()

func _physics_process(_delta: float):
	var full_count: int = 0
	for link in _links: full_count += link.atom_count()
	for link in _links:
		if _is_centered(link):
			link.set_merge(Vector2.ZERO, full_count, 0.2)
		else:
			var dir := (position - link.position).normalized()
			link.set_merge(dir * merge_speed, full_count)

func add_links(links: Array[AtomLinker]):
	var calc_pos: bool = _links.size() == 0
	var pos_total: Vector2 = Vector2.ZERO
	for link in links:
		if not contains_link(link):
			link.destroyed.connect(_on_link_destroyed)
			_links.append(link)
			pos_total += link.position
	if calc_pos: position = pos_total / links.size()

func contains_link(link: AtomLinker) -> bool:
	for l in _links:
		if l == link: return true
	return false

func destroy():
	while _links.size() > 0:
		_remove_link(_links[0])
	queue_free()

func _remove_link(link: AtomLinker):
	link.set_merge(Vector2.ZERO)
	_links.remove_at(_links.find(link))

func _on_link_destroyed(link: AtomLinker):
	link.destroyed.disconnect(_on_link_destroyed)
	_remove_link(link)

func _is_centered(link: AtomLinker) -> bool:
	return (link.position - position).length() < center

func _merge_centered():
	var merge_list: Array[AtomLinker] = []
	for link in _links:
		if _is_centered(link): merge_list.append(link)
	if merge_list.size() >= 2:
		var new_link := _link_scene.instantiate() as AtomLinker
		add_sibling(new_link)
		new_link.position = position
		for link in merge_list:
			var atom_list: Array[Atom] = []
			for child in link.get_children():
				atom_list.append((child as AtomLinkCone).atom)
			new_link.add_atoms(atom_list)
			link.destroy()
		if _links.size() == 0:
			destroy()
		else:
			for link in merge_list:
				_remove_link(link)
			_links.append(new_link)
