class_name Agent

extends Actor

var movement_urges : Dictionary # movement urges of the agent (String : float) pairs in dictionary
var energy_calculations : Energy # parameters needed for energy calculations (String : float) pairs in dictionary
var a_max : float # max acceleration
var velocity_params : Dictionary # params for velocity (String : float) pairs
var distance_params : Dictionary # params for distance stuff (String : float) pairs
var beta : float # angle the agent can see
var influences : Dictionary # influences on other agents or the terrain (String : float) pairs, where the string is the type of the agent that gets influenced
var constraints : Vector3 # per axis constraint vector

var velocity : Vector3 # actual velocity of this agent
var individual_world_center : Vector3 #world center for this specific agent

func take_values(template : ActorTemplate):
	movement_urges = template.movement_urges
	energy_calculations = template.energy_calculations
	a_max = template.a_max
	velocity_params = template.velocity_params
	constraints = template.constraints
	distance_params = template.distance_params
	beta = template.beta
	influences = template.influences
	super.take_values(template)

func movement(neighbours : Array[Actor], terrain : Terrain):
	var acceleration : Vector3 = Vector3.ZERO
	
	var alignment : Vector3 = Vector3.ZERO
	var cohesion : Vector3 = Vector3.ZERO
	var separation : Vector3 = Vector3.ZERO
	var center : Vector3 = Vector3.ZERO
	var random : Vector3 = Vector3.ZERO
	var bias : Vector3 = Vector3.ZERO
	var floor_urge : Vector3 = Vector3.ZERO
	var gradient : Vector3 = Vector3.ZERO	
	var slope : Vector3 = Vector3.ZERO
	var normal : Vector3 = Vector3.ZERO
	
	if movement_urges.has(Database.movement_urges.ALIGNMENT):
		var count : float = 0
		for neighbour in neighbours:
			if neighbour.id == self.id:
				continue
			if neighbour is Agent:
				if neighbour.influences.has(self.type):
					#if id == 1:
						#print("neighbour: " + neighbour.name)
						#print("neighbour velocity: " + str(neighbour.velocity))
					alignment += neighbour.velocity * neighbour.influences[self.type]
					count += 1 * neighbour.influences[self.type]
		#print("count: " + str(count))
		if count != 0:
			alignment /= count
		#alignment.normalized()
		acceleration += alignment * movement_urges[Database.movement_urges.ALIGNMENT]
	
	if movement_urges.has(Database.movement_urges.COHESION):
		var count : float = 0
		for neighbour in neighbours:
			if neighbour.influences.has(self.type):
				cohesion += neighbour.position * neighbour.influences[self.type]
				count += 1 * neighbour.influences[self.type]
		if count != 0:
			cohesion /= count
		#cohesion.normalized()
		acceleration += cohesion * movement_urges[Database.movement_urges.COHESION]
		
	if movement_urges.has(Database.movement_urges.SEPARATION):
		var count : float = 0
		for neighbour in neighbours:
			var neighbour_dir = self.position - neighbour.position
			var dist = neighbour_dir.length()
			var sep_dist = distance_params[Database.distance_params.SEPARATION]
			if dist <= sep_dist:
				if neighbour.influences.has(self.type):
					var rev = neighbour_dir * (sep_dist - dist)
					separation += rev * neighbour.influences[self.type]
					count += 1 * neighbour.influences[self.type]
		if count != 0:
			separation /= count
		# separation.normalized()
		acceleration += separation * movement_urges[Database.movement_urges.SEPARATION]
	
	if movement_urges.has(Database.movement_urges.CENTER):
		center = individual_world_center - position
		#center.normalized()
		acceleration += center * movement_urges[Database.movement_urges.CENTER]
	
	if movement_urges.has(Database.movement_urges.RANDOM):
		var rng = RandomNumberGenerator.new()
		random = Vector3(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0))
		#random.normalized()
		acceleration += random * movement_urges[Database.movement_urges.RANDOM]
	
	if movement_urges.has(Database.movement_urges.BIAS):
		bias = movement_urges[Database.movement_urges.BIAS]
		#bias.normalized()
		acceleration += bias
	
	if movement_urges.has(Database.movement_urges.FLOOR):
		floor_urge = -Vector3.UP * pow(terrain.get_height_at(position), 2)
		acceleration += floor_urge * movement_urges[Database.movement_urges.FLOOR]
	
	var offset_x : Vector3 = Vector3(0.5 * terrain.distance_between_vertices, 0, 0)
	var offset_z : Vector3 = Vector3(0, 0, 0.5 * terrain.distance_between_vertices)
	
	if movement_urges.has(Database.movement_urges.GRADIENT) or movement_urges.has(Database.movement_urges.SLOPE):
		gradient = Vector3(terrain.get_height_at(position + offset_x) -
										terrain.get_height_at(position - offset_x), 0,
										terrain.get_height_at(position + offset_z) -
										terrain.get_height_at(position - offset_z))
		if movement_urges.has(Database.movement_urges.GRADIENT):
			acceleration += gradient * movement_urges[Database.movement_urges.GRADIENT]
		
		if gradient == Vector3.ZERO:
			slope = gradient
		else:
			var norm_grad = gradient.normalized() * terrain.distance_between_vertices * 0.5
			var grad_quot
			if gradient.length() != 0:
				grad_quot = Vector3(norm_grad.x, 0, norm_grad.z)
			
			var h1 = terrain.get_height_at(position - grad_quot)
			var h2 = terrain.get_height_at(position + grad_quot)
			var diff = h2 - h1
			
			if diff >= 0.0:
				slope = Vector3(gradient.x, -diff, gradient.z)
			else:
				slope = -Vector3(gradient.x, -diff, gradient.z)
			
		acceleration += slope * movement_urges[Database.movement_urges.SLOPE]
	
	if movement_urges.has(Database.movement_urges.NORMAL):
		var plus_z = terrain.get_height_at(position + offset_z)
		var minus_z = terrain.get_height_at(position - offset_z)
		var plus_x = terrain.get_height_at(position + offset_x)
		var minus_x = terrain.get_height_at(position - offset_x)
		var diff_x = plus_x - minus_x
		var diff_z = plus_z - minus_z
		if is_nan(plus_x) or is_nan(minus_x) or is_nan(plus_z) or is_nan(minus_x):
			print("position: " + str(position))
			print("offset_x: " + str(offset_x) + " offset_z: " + str(offset_z))
			print("terrain_height for normal calculation: plus z: " + str(plus_z) + " minus z: " + str(minus_z)
			+ " plus_x: " + str(plus_x) + " minus x: " + str(minus_x))
			print("position")
			print("ALARM")
			terrain.get_height_at(position + offset_x)
			terrain.get_height_at(position - offset_x)
			terrain.get_height_at(position + offset_z)
			terrain.get_height_at(position - offset_z)
		normal = Vector3(0, diff_z, 1).cross(Vector3(1, diff_x, 0))
		acceleration += normal * movement_urges[Database.movement_urges.NORMAL]


	acceleration = Vector3(acceleration.x * constraints.x, acceleration.y * constraints.y, acceleration.z * constraints.z)
	
	if acceleration.length() > a_max and acceleration.length() != 0:
		acceleration = acceleration * (a_max / acceleration.length())
	
	var new_velocity = velocity + acceleration
	if new_velocity.length() > velocity_params[Database.velocity_params.MAX] and new_velocity.length() != 0:
		new_velocity = new_velocity * (velocity_params[Database.velocity_params.MAX] / new_velocity.length())
	
	

	if movement_urges.has(Database.movement_urges.PACE):
		var pace_keeping = movement_urges[Database.movement_urges.PACE]
		if pace_keeping > 0.0:
			var new_velocity_norm = new_velocity
			if new_velocity_norm.length() > velocity_params[Database.velocity_params.NORM] and new_velocity_norm.length() != 0:
				new_velocity_norm = new_velocity_norm * (velocity_params[Database.velocity_params.NORM] / new_velocity_norm.length())
			new_velocity = pace_keeping * new_velocity_norm + (1 - pace_keeping) * new_velocity
	
	var new_pos = position + new_velocity
	var floor_height = terrain.get_height_at(new_pos)
	
	if movement_urges.has(Database.movement_urges.NOCLIP):
		if movement_urges[Database.movement_urges.NOCLIP] == 0 and floor_height > new_pos.y:
			new_pos = Vector3(new_pos.x, floor_height, new_pos.z)
	
	velocity = new_velocity
	position = new_pos
	if velocity.length() > 0:
		look_at(position + velocity)
	adjust_energy_move()
	
	if is_nan(velocity.x) or is_nan(velocity.y) or is_nan(velocity.z):
		print("----------------------ALAAAAARM---------------------------")
		print(name)
		print("alignment: " + str(alignment))
		print("cohesion: " + str(cohesion))
		print("separation: " + str(separation))
		print("center: " + str(center))
		print("random: " + str(random))
		print("bias: " + str(bias))
		print("floor: " + str(floor_urge))
		print("gradient: " + str(gradient))
		print("slope: " + str(slope))
		print("normal: " + str(normal))
		print("velocity: " + str(velocity))
		print("position: " + str(position))
		print("----------------------ALAAAAARM---------------------------")

func adjust_energy_move():
	match energy_calculations.move_mode:
		energy_calculations.move.CONST:
			energy -= energy_calculations.move_value
		energy_calculations.move.DISTANCE:
			energy -= velocity.length()

func get_neighbours(actors : Array[Actor]) -> Array[Actor]:
	var neighbours : Array[Actor]
	
	for actor in actors:
		if actor.id == id:
			break
		
		var other_pos = actor.get_position()
		var dir_to_other = other_pos - self.position
		var forward = -self.basis.z
		var angle = forward.angle_to(dir_to_other)
		if angle < deg_to_rad(beta) / 2.0 and dir_to_other.length() <= distance_params[Database.distance_params.VIEW]:
			neighbours.append(actor)
	return neighbours
	
