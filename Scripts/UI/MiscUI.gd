class_name MiscUI extends PanelContainer

@export
var first_gen_obj : UIList
@export
var t_obj : FloatValueUI
@export
var terrain_size_obj : FloatValueUI
@export
var use_rng_seed_obj : BoolValueUI
@export
var rng_seed_obj : StringValueUI

func fill(database : Database):
	for member in database.first_generation:
		first_gen_obj.add_item()
		var obj = first_gen_obj.get_item(first_gen_obj.size() - 1)
		obj.set_value(member)
	
	t_obj.set_value(database.t)
	terrain_size_obj.set_value(database.terrain_size)
	rng_seed_obj.set_value(str(database.rng_seed))
	use_rng_seed_obj.set_value(database.use_rng_seed)

func get_data(database : Database):
	database.first_generation.clear()
	for member : UIListElementString in first_gen_obj.list_elements:
		database.first_generation.append(member.value)
	database.t = t_obj.value
	database.terrain_size = terrain_size_obj.value
	database.rng_seed = int(rng_seed_obj.value)
	database.use_rng_seed = use_rng_seed_obj.value

func clear():
	first_gen_obj.clear()
	t_obj.set_value(0)
	terrain_size_obj.set_value(0)
	use_rng_seed_obj.set_value(false)
	rng_seed_obj.set_value("")

func lock():
	first_gen_obj.lock()
	t_obj.lock()
	terrain_size_obj.lock()
	rng_seed_obj.lock()
	use_rng_seed_obj.lock()

func unlock_seed():
	rng_seed_obj.unlock()
	use_rng_seed_obj.unlock()
