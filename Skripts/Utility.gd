class_name Utility

static func select_random_from_array(arr : Array, rng : RandomNumberGenerator):
	if arr.size() == 0:
		print("cannot select a random element from an empty array")
		return
	
	var selected = rng.randi_range(0, arr.size() - 1)
	return arr[selected]
	
static func vector_max(v : Vector3) -> float:
	return max(v.x, v.y, v.z)

static func vector_min(v : Vector3) -> float:
	return min(v.x, v.y, v.z)
