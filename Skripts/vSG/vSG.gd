extends Node3D

var l_system : LSystem
var actors : Array[Actor]
var agents : Array[Agent]
var artifacts : Array[Artifact]

var database : Database

var id : int = 0
var terrain : Terrain
var terrain_changed : bool = false

var reproduce : bool = false
var play : bool = false
var step : bool = false

var agent_scene : PackedScene = preload("res://Scenes/Agent.tscn")
var artifact_scene : PackedScene = preload("res://Scenes/Artifact.tscn")
var terrain_scene : PackedScene = preload("res://Scenes/Terrain.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	database = Database.getInstance()
	# database.save_data()
	# database.load_data()
	
	terrain = terrain_scene.instantiate()
	terrain.generate_terrain(database.t, database.terrain_size)
	get_tree().root.add_child.call_deferred(terrain)
	
	for actor in database.first_generation:
		for template in database.templates:
			if actor == template.type:
				var obj = instantiate(template)
				obj.energy = 30
				obj.id = get_new_id()
				obj.position = Vector3(0, 0, 0)
				# obj.velocity = Vector3.UP
				get_tree().root.add_child.call_deferred(obj)
	
	l_system = LSystem.new()
	l_system.productions = database.productions

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if play or step:
		if reproduce:
			apply_productions()
		reproduce = !reproduce
		#apply_productions()
		
		movement()
		if (len(artifacts) == 0):
			return
		if !terrain_changed:
			return
		recalculate_terrain()
		terrain_changed = false
		step = false
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_SPACE:
			play = !play
		elif event.keycode == KEY_RIGHT:
			step = true

func instantiate(template : ActorTemplate) -> Actor:
	if template is AgentTemplate:
		var obj : Agent = agent_scene.instantiate()
		obj.take_values(template)
		obj.id = get_new_id()
		actors.append(obj)
		agents.append(obj)
		return obj
	else:
		var obj : Artifact = artifact_scene.instantiate()
		obj.take_values(template)
		obj.id = get_new_id()
		actors.append(obj)
		artifacts.append(obj)
		terrain_changed = true
		return obj

func apply_productions():
	var arr = l_system.apply_productions(actors)
	var ids_apply_productions_to = arr[0]
	var persist = arr[1]
	var types_to_instantiate = arr[2]
	
	var instantiated : Array
	for to_inst_arr in types_to_instantiate:
		var batch : Array
		for to_inst in to_inst_arr:
			for template in database.templates:
				if to_inst == template.type:
					var obj = instantiate(template)
					batch.append(obj)
		instantiated.append(batch)
	
	var remove : Array[Agent]
	var i : int = 0
	for id_a_p in ids_apply_productions_to:
		for agent in agents: 
			if id_a_p == agent.id:
				var successors = instantiated[i]
				#print("i: " + str(i) + " successor_count: " + str(len(successors)))
				#for successor in successors:
					#print(successor.get_parent())
				for successor in successors:
					
					successor.back_reference = agent
					successor.position = agent.position
					successor.name = successor.type + str(successor.id)
					if successor is Agent:
						successor.velocity = agent.velocity
						if agent.movement_urges.has(database.movement_urges.SEED):
							successor.individual_world_center = successor.position
					get_tree().get_root().add_child(successor)
					
				calculate_energies(successors, agent, persist[i])
				if !persist[i]:
					remove.append(agent)
		i += 1
	
	# print("------------productions applied----------------")
	
	for r in remove:
		agents.erase(r)
		actors.erase(r)
		r.queue_free()

func movement():
	for agent in agents:
		agent.movement(actors, terrain)

func recalculate_terrain():
	terrain.update_terrain(artifacts)

func calculate_energies(successors : Array, predecessor : Agent, persist : bool):
	var count = successors.size()
	match predecessor.energy_calculations.successor_mode:
		Energy.successor.CONST:
			var value = predecessor.energy_calculations.successor_value
			for successor in successors:
				successor.energy = value
		Energy.successor.INHERIT:
			var factor = predecessor.energy_calculations.successor_value
			for successor in successors:
				successor.energy = predecessor.energy * factor
		Energy.successor.DISTRIBUTE:
			var offset = predecessor.energy_calculations.successor_value
			if persist:
				count += 1
			for successor in successors:
				successor.energy = (predecessor.energy - offset) / float(count)
			predecessor.energy = 0
		Energy.successor.CONSTDIST:
			var amount = predecessor.energy_calculations.successor_value
			var offset = predecessor.energy_calculations.successor_value_constdist
			for successor in successors:
				successor.energy = min(
					amount, 
					(predecessor.energy - offset)/ float(count))
		_:
			print("energy l system mode unknown")
	
	if !persist:
		return
	
	match predecessor.energy_calculations.predecessor_mode:
		Energy.predecessor.CONST:
			var value = predecessor.energy_calculations.predecessor_value
			predecessor.energy -= value
		Energy.predecessor.PER_SUCCESSOR:
			var factor = predecessor.energy_calculations.predecessor_value
			predecessor.energy -= count * factor
		Energy.predecessor.EQUAL:
			predecessor.energy = successors[0].energy
		Energy.predecessor.CONSTDIST:
			var offset = predecessor.energy_calculations.predecessor_value
			predecessor.energy = predecessor.energy - offset - count * successors[0].energy

func get_new_id() -> int:
	var ret = id
	id += 1
	return ret
