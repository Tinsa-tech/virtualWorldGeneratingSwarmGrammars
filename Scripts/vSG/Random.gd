## Thread-safe random number generator
class_name Random

var rng : RandomNumberGenerator
var mutex : Mutex

func _init() -> void:
	rng = RandomNumberGenerator.new()
	mutex = Mutex.new()

func randomize() -> void:
	rng.randomize()

func set_seed(seed : int) -> void:
	rng.set_seed(seed)

func get_seed() -> int:
	return rng.get_seed()

func rand_weighted(weights : PackedFloat32Array) -> int:
	var ret : int 
	mutex.lock()
	ret = rng.rand_weighted(weights)
	mutex.unlock()
	return ret

func randf() -> float:
	var ret : float
	mutex.lock()
	ret = rng.randf()
	mutex.unlock()
	return ret

func randf_range(from : float, to : float) -> float:
	var ret : float
	mutex.lock()
	ret = rng.randf_range(from, to)
	mutex.unlock()
	return ret

func randfn(mean : float = 0.0, deviation : float = 1.0) -> float:
	var ret : float
	mutex.lock()
	ret = rng.randfn(mean, deviation)
	mutex.unlock()
	return ret

func randi() -> int:
	var ret : int
	mutex.lock()
	ret = rng.randi()
	mutex.unlock()
	return ret

func randi_range(from : int, to : int) -> int:
	var ret : int
	mutex.lock()
	ret = rng.randi_range(from, to)
	mutex.unlock()
	return ret
