class_name vSG extends Node3D

var l_system : LSystem
var actors : Array[ActorObject]
var agents : Array[AgentObject]
var artifacts : Array[ArtifactObject]

var database : Database

var id : int = 0
var terrain : Terrain
var terrain_changed : bool = false

var reproduce : bool = false
var play : bool = false
var step : bool = false

var octree : Octree
var grid : SpaceGrid

var finished : bool = false

@export
var hud : HUD
@export
var camera : FreeLookCamera
@export
var parent : Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	database = Database.new()
	# database.save_data()
	database.random()
	database.t = 1
	database.terrain_size = 100
	var terrain_size = database.t * database.terrain_size
	camera.position = Vector3(0, terrain_size / 4, terrain_size /2)
	camera.rotation = Vector3(-45, 0, 0)
	
	terrain = SceneManager.get_instance().terrain_scene.instantiate()
	terrain.generate_terrain(database.t, database.terrain_size)
	parent.add_child.call_deferred(terrain)
	
	#octree = Octree.new(10, database.t * database.terrain_size / 2)
	
	var min_view_dist = 1000
	for template in database.templates:
		if template is AgentTemplate:
			if template.distance_params[Database.distance_params.VIEW] < min_view_dist:
				min_view_dist = template.distance_params[Database.distance_params.VIEW]
	
	grid = SpaceGrid.new(database.t * database.terrain_size, min_view_dist)
	
	#for i in range(1000):
		#database.first_generation.append(database.templates[0].type)
	
	for actor in database.first_generation:
		for template in database.templates:
			if actor == template.type:
				var obj = instantiate(template)
				var real_actor = obj.actor
				real_actor.energy = 30
				real_actor.id = get_new_id()
				real_actor.actor_position = Vector3(0, 0, 0)
				obj.position = Vector3.ZERO
				# obj.velocity = Vector3.UP
				parent.add_child.call_deferred(obj)
				# add_to_octree(real_actor)
				add_to_grid(obj)
	
	l_system = LSystem.new()
	l_system.productions = database.productions
	
	hud.set_agent_count(agents.size())
	hud.set_artifact_count(artifacts.size())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if finished: 
		return
	if play or step:
		if reproduce:
			apply_productions()
		reproduce = !reproduce
		# apply_productions()
		
		hud.set_agent_count(agents.size())
		hud.set_artifact_count(artifacts.size())
		
		#movement()
		var task_id = WorkerThreadPool.add_group_task(movement_agent, agents.size())
		WorkerThreadPool.wait_for_group_task_completion(task_id)
		update_agent_positions()
		
		# update_octree()
		update_grid()
		
		#if delta >= 5:
			#kill_all_agents()
		if agents.size() > 2000 or artifacts.size() > 2000 or agents.size() <= 0:
			clean_up()
			print("finished")
			finished = true
			return
		
		
		step = false
		
		if (len(artifacts) == 0):
			return
		if !terrain_changed:
			return
		recalculate_terrain()
		terrain_changed = false

		
func update_agent_positions():
	for agent in agents:
		agent.update_position(terrain)

func update_octree():
	octree = Octree.new(10, database.t * database.terrain_size / 2)
	for actor in actors:
		var ele : OctreeElement = OctreeElement.new()
		ele.position = actor.position
		ele.obj = actor.actor
		octree.add_element(ele)

func update_grid():
	grid.update_grid()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_SPACE:
			play = !play
		elif event.keycode == KEY_RIGHT:
			step = true

func instantiate(template : ActorTemplate) -> ActorObject:
	if template is AgentTemplate:
		var obj : AgentObject = SceneManager.get_instance().agent_scene.instantiate()
		var agent : Agent = Agent.new()
		agent.take_values(template)
		agent.id = get_new_id()
		obj.actor = agent
		obj.instantiate()
		actors.append(obj)
		agents.append(obj)
		return obj
	else:
		var obj : ArtifactObject = SceneManager.get_instance().artifact_scene.instantiate()
		var artifact : Artifact = Artifact.new()
		artifact.take_values(template)
		artifact.id = get_new_id()
		obj.actor = artifact
		actors.append(obj)
		artifacts.append(obj)
		terrain_changed = true
		return obj

func apply_productions():
	var arr = l_system.apply_productions(actors)
	if arr.is_empty():
		return
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
	
	var remove : Array[AgentObject]
	var i : int = 0
	for id_a_p in ids_apply_productions_to:
		for agent_obj in agents:
			var agent = agent_obj.actor 
			if id_a_p == agent.id:
				var successors = instantiated[i]
				#print("i: " + str(i) + " successor_count: " + str(len(successors)))
				#for successor in successors:
					#print(successor.get_parent())
				for successor_obj in successors:
					var successor = successor_obj.actor
					successor.back_reference = agent
					successor.actor_position = agent.actor_position
					successor_obj.position = agent_obj.position
					successor_obj.name = successor.type + str(successor.id)
					if successor is Agent:
						successor.velocity = agent.velocity
						if agent.movement_urges.has(database.movement_urges.SEED):
							successor.individual_world_center = agent.actor_position
					else:
						if successor.influence_on_terrain > 0:
							terrain.influencers.append(successor)
					parent.add_child(successor_obj)
					# add_to_octree(successor)
					add_to_grid(successor_obj)
					
				calculate_energies(successors, agent, persist[i])
				if !persist[i]:
					remove.append(agent_obj)
		i += 1
	
	# print("------------productions applied----------------")
	
	for r in remove:
		agents.erase(r)
		actors.erase(r)
		r._on_destroyed()
		r.queue_free()

func movement():
	for agent in agents:
		# agent.movement(agent.get_neighbours_octree(octree), terrain)
		# agent.movement(agent.get_neighbours(actors), terrain)
		agent.actor.movement(agent.actor.get_neighbours_grid(grid), terrain)

func movement_agent(agent_index : int):
	var agent = agents[agent_index].actor
	var neighbours = agent.get_neighbours_grid(grid)
	agent.movement(neighbours, terrain)
	
func recalculate_terrain():
	terrain.update_terrain()


func calculate_energies(successors : Array, predecessor : Agent, persist : bool):
	var count = successors.size()
	match predecessor.energy_calculations.successor_mode:
		Energy.successor.CONST:
			var value = predecessor.energy_calculations.successor_value
			for successor in successors:
				successor.actor.energy = value
		Energy.successor.INHERIT:
			var factor = predecessor.energy_calculations.successor_value
			for successor in successors:
				successor.actor.energy = predecessor.energy * factor
		Energy.successor.DISTRIBUTE:
			var offset = predecessor.energy_calculations.successor_value
			if persist:
				count += 1
			for successor in successors:
				successor.actor.energy = (predecessor.energy - offset) / float(count)
			predecessor.energy = 0
		Energy.successor.CONSTDIST:
			var amount = predecessor.energy_calculations.successor_value
			var offset = predecessor.energy_calculations.successor_value_constdist
			for successor in successors:
				successor.actor.energy = min(
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
			predecessor.energy = successors[0].actor.energy
		Energy.predecessor.CONSTDIST:
			var offset = predecessor.energy_calculations.predecessor_value
			predecessor.energy = predecessor.energy - offset - count * successors[0].actor.energy

func get_new_id() -> int:
	var ret = id
	id += 1
	return ret

func add_to_octree(obj : Actor):
	var octree_element = OctreeElement.new()
	octree_element.position = obj.actor_position
	octree_element.obj = obj
	octree.add_element(octree_element)

func add_to_grid(obj : ActorObject):
	var grid_element = GridElement.new(obj)
	grid_element.position = obj.actor.actor_position
	grid.add_element(grid_element)

func kill_all_agents():
	for agent in agents:
		agent._on_destroyed()
		actors.erase(agent)
		agent.queue_free()
	
	agents.clear()
		
func clean_up():
	kill_all_agents()
	hud.set_agent_count(agents.size())
	hud.set_artifact_count(artifacts.size())
	recalculate_terrain()
	terrain.smooth_normals()
	grid.clean_up()
