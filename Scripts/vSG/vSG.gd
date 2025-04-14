class_name vSG

enum finish_code {AGENTS_DEAD, TOO_MANY_AGENTS, TOO_MANY_ARTIFACTS, TOO_MANY_STEPS, MANUAL}

var l_system : LSystem
var actors : Array[ActorObject]
var agents : Array[AgentObject]
var artifacts : Array[ArtifactObject]
var connections : Array[Node3D] = []

var database : Database

var id : int = 0
var terrain : Terrain
var terrain_changed : bool = false

var reproduce : bool = false
var play : bool = false

var octree : Octree
var grid : SpaceGrid

var finished : bool = false
var keep_running : bool = false

@export
var editable : bool = false

var step_count : int = 0

var hud : SwarmHUD
var parent : Node3D

var random : Random

signal on_finished(reason : int)


func _init(data : Database, camera : FreeLookCamera, parent_node : Node3D, 
			heads_up_display : SwarmHUD):
	database = data
	parent = parent_node
	hud = heads_up_display
	
	random = Random.new()
	if database.use_rng_seed:
		random.set_seed(database.rng_seed)
	else:
		random.randomize()
		database.rng_seed = random.get_seed()
	
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
	
	grid = SpaceGrid.new(min_view_dist)
	
	#for i in range(1000):
		#database.first_generation.append(database.templates[0].type)
	
	for actor in database.first_generation:
		for template in database.templates:
			if actor == template.type:
				var obj = instantiate(template)
				var real_actor = obj.actor
				real_actor.energy = 30
				real_actor.actor_position = Vector3(0, 0, 0)
				obj.position = Vector3.ZERO
				# obj.velocity = Vector3.UP
				# add_to_octree(real_actor)
				add_to_grid(obj)
	
	l_system = LSystem.new()
	l_system.productions = database.productions
	
	hud.set_agent_count(agents.size())
	hud.set_artifact_count(artifacts.size())
	hud.set_step_count(step_count)

func step() -> void:
	if reproduce:
		apply_productions()
	reproduce = !reproduce
	# apply_productions()
	
	hud.set_agent_count(agents.size())
	hud.set_artifact_count(artifacts.size())
	
	if agents.size() > 2000 or terrain.new_influencers.size() > 100 or agents.size() <= 0 or step_count > 100:
		if !keep_running:
			if agents.size() <= 0: 
				on_finished.emit(finish_code.AGENTS_DEAD)
			elif agents.size() > 2000:
				on_finished.emit(finish_code.TOO_MANY_AGENTS)
			elif terrain.new_influencers.size() > 100:
				on_finished.emit(finish_code.TOO_MANY_ARTIFACTS)
			elif step_count > 100:
				on_finished.emit(finish_code.TOO_MANY_STEPS)
		clean_up()
		return

	#movement()
	var task_id = WorkerThreadPool.add_group_task(movement_agent, agents.size())
	WorkerThreadPool.wait_for_group_task_completion(task_id)
	update_agent_positions()

	# update_octree()
	update_grid()
	
	step_count += 1
	hud.set_step_count(step_count)
	
	if (len(artifacts) == 0):
		return
	if !terrain_changed:
		return
	recalculate_terrain()
	terrain_changed = false

func update_agent_positions():
	for agent in agents:
		agent.update_position(terrain, random)

func update_octree():
	octree = Octree.new(10, database.t * database.terrain_size / 2)
	for actor in actors:
		var ele : OctreeElement = OctreeElement.new()
		ele.position = actor.position
		ele.obj = actor.actor
		octree.add_element(ele)

func update_grid():
	grid.update_grid()

func instantiate(template : ActorTemplate) -> ActorObject:
	if template is AgentTemplate:
		var obj : AgentObject = SceneManager.get_instance().agent_scene.instantiate()
		var agent : Agent = Agent.new()
		agent.take_values(template)
		agent.id = get_new_id()
		obj.actor = agent
		obj.instantiate()
		obj.name = agent.type + str(agent.id)
		actors.append(obj)
		agents.append(obj)
		parent.add_child(obj)
		obj.set_color(database.colors[template.type])
		obj.editable = editable
		return obj
	else:
		var obj : ArtifactObject = SceneManager.get_instance().artifact_scene.instantiate()
		var artifact : Artifact = Artifact.new()
		artifact.take_values(template)
		artifact.id = get_new_id()
		obj.actor = artifact
		obj.name = artifact.type + str(artifact.id)
		actors.append(obj)
		artifacts.append(obj)
		terrain_changed = true
		parent.add_child(obj)
		obj.set_color()
		obj.editable = editable
		return obj

func apply_productions():
	var arr = l_system.apply_productions(actors, random)
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
				replace_agent(agent, successors)
				calculate_energies(agent, successors, persist[i])
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

func replace_agent(agent_parent : Agent, new_actors : Array):
	for new_actor_obj in new_actors:
		var new_actor = new_actor_obj.actor
		new_actor.actor_position = agent_parent.actor_position
		new_actor_obj.position = agent_parent.actor_position
		
		if new_actor is Agent:
			if agent_parent.back_reference:
				new_actor.back_reference = agent_parent.back_reference
			new_actor.velocity = agent_parent.velocity
			if agent_parent.seed:
				new_actor.individual_world_center = agent_parent.actor_position
		else:
			if agent_parent.back_reference:
				new_actor.back_reference = agent_parent.back_reference
			agent_parent.back_reference = new_actor
			if new_actor.back_reference:
				connect_with_line(new_actor.back_reference.actor_position, new_actor.actor_position)
			if new_actor.influence_on_terrain > 0:
				terrain.add_influencer(new_actor)
		# add_to_octree(successor)
		add_to_grid(new_actor_obj)

func calculate_energies(predecessor : Agent, successors : Array, persist : bool):
	var count = successors.size()
	if predecessor.energy <= 0:
		for successor in successors:
			successor.actor.energy = predecessor.energy_calculations.zero_energy
		
		return
	
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
	step_count = 0
	kill_all_agents()
	# hud.set_agent_count(agents.size())
	hud.set_artifact_count(artifacts.size())
	recalculate_terrain()
	terrain.smooth_normals()
	if !keep_running:
		grid.clean_up()
		finished = true

func add_actor(type : String) -> ActorObject:
	var template : ActorTemplate
	for t in database.templates:
		if t.type == type:
			template = t
	var obj : ActorObject = instantiate(template)
	obj.position = Vector3(0,terrain.get_height_at(Vector3.ZERO),0)
	obj.actor.actor_position = obj.position
	if obj is ArtifactObject:
		if obj.actor.influence_on_terrain > 0:
			terrain.add_influencer(obj.actor)
			terrain.update_terrain()
			obj.moved.connect(terrain._on_influencer_moved)
		obj.set_color()
	hud.set_agent_count(agents.size())
	hud.set_artifact_count(artifacts.size())
	add_to_grid(obj)
	return obj

func connect_with_line(pointA : Vector3, pointB : Vector3):
	if pointA.is_equal_approx(pointB):
		return
	var connector : Node3D = SceneManager.get_instance().connector.instantiate()
	parent.add_child(connector)
	connector.name = "Connector"
	var ab = pointB - pointA
	var mid = ab * 0.5 + pointA
	connector.position = mid
	connector.scale.z = ab.length()
	connector.look_at(pointB)
	connections.append(connector)

func restart_swarm():
	for actor in actors:
		actor._on_destroyed()
		actor.queue_free()
	actors.clear()
	agents.clear()
	artifacts.clear()
	for connection in connections:
		connection.queue_free()
	connections.clear()
	terrain.queue_free()
	grid.clean_up()
	
	if database.use_rng_seed:
		random.set_seed(database.rng_seed)
	else:
		random.randomize()
	
	terrain = SceneManager.get_instance().terrain_scene.instantiate()
	terrain.generate_terrain(database.t, database.terrain_size)
	parent.add_child.call_deferred(terrain)
	
	var min_view_dist = 1000
	for template in database.templates:
		if template is AgentTemplate:
			if template.distance_params[Database.distance_params.VIEW] < min_view_dist:
				min_view_dist = template.distance_params[Database.distance_params.VIEW]
	
	grid = SpaceGrid.new(min_view_dist)
	
	for actor in database.first_generation:
		for template in database.templates:
			if actor == template.type:
				var obj = instantiate(template)
				var real_actor = obj.actor
				real_actor.energy = 30
				real_actor.actor_position = Vector3(0, 0, 0)
				obj.position = Vector3.ZERO
				add_to_grid(obj)
	
	hud.set_agent_count(agents.size())
	hud.set_artifact_count(artifacts.size())
	
	finished = false

#region hiding and showing objects
func hide_agents():
	for actor in actors:
		if actor is AgentObject:
			actor.hide()

func show_agents():
	for actor in actors:
		if actor is AgentObject:
			actor.show()

func hide_artifacts():
	for actor in actors:
		if actor is ArtifactObject:
			actor.hide()

func show_artifacts():
	for actor in actors:
		if actor is ArtifactObject:
			actor.show()

func hide_connections():
	for connection in connections:
		connection.hide()

func show_connections():
	for connection in connections:
		connection.show()

func hide_terrain():
	terrain.hide()

func show_terrain():
	terrain.show()

#endregion
