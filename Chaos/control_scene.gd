extends Node2D

var atom_scene: PackedScene = preload("res://Chaos/Atoms/atom.tscn")
var click_wave_scene: PackedScene = preload("res://Chaos/click_wave.tscn")
var atom_link_scene: PackedScene = preload("res://Chaos/Atoms/atom_linker.tscn")
var merge_scene: PackedScene = preload("res://Chaos/Atoms/link_merger.tscn")
@onready var panel: Node2D = $"Atom Panel"
@onready var camera: Camera2D = $"Camera"

const group_name := "merge_set"

func _ready():
	randomize()
	var atoms: Array[Atom] = []
	for type in Atom.AtomType:
		var count: int = randi_range(10, 25)
		for _i in count:
			var atom: Atom = atom_scene.instantiate() as Atom
			atom.type = Atom.AtomType[type]
			atom.on_link.connect(_on_link)
			atoms.append(atom)
			add_child(atom)
	var size: float = (atoms.size() - 10) * 0.003 + 1
	for atom in atoms:
		atom.position = Vector2(randf_range(65, 3840 * size - 65), randf_range(65, 2160 * size - 65))
	camera.zoom = Vector2(1 / size, 1 / size)
	panel.scale = Vector2(size, size)

func _input(event):
	if event is InputEventMouseButton:
		var evt: InputEventMouseButton = event as InputEventMouseButton
		if evt.button_index == 1 and evt.is_released():
			var wave := click_wave_scene.instantiate() as Node2D
			wave.global_position = panel.to_global(evt.global_position)
			add_child(wave)

func _on_link(atom1: Atom, atom2: Atom):
	if atom1.link == null and atom2.link == null:
		var link := atom_link_scene.instantiate() as AtomLinker
		link.add_atoms([atom1, atom2])
		link.position = atom1.position + (atom2.position - atom1.position) / 2.0
		add_child(link)
	elif (atom1.link == null and atom2.link != null) or (atom1.link != null and atom2.link == null):
		var single := atom1 if atom1.link == null else atom2
		var linked := atom2 if atom1.link == null else atom1
		linked.link.add_atoms([single])
	elif atom1.link != atom2.link:
		var merge1: LinkMerger
		var merge2: LinkMerger
		var nodes := get_tree().get_nodes_in_group(group_name)
		for n in nodes:
			var m := n as LinkMerger
			if m.contains_link(atom1.link): merge1 = m
			if m.contains_link(atom2.link): merge2 = m
		if merge1 == null and merge2 == null:
			var m: LinkMerger = merge_scene.instantiate() as LinkMerger
			add_child(m)
			m.add_to_group(group_name)
			m.add_links([atom1.link, atom2.link])
		elif (merge1 == null and merge2 != null) or (merge1 != null and merge2 == null):
			var m: LinkMerger = merge1 if merge1 != null else merge2
			m.add_links([atom1.link, atom2.link])
