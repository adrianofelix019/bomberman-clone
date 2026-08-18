extends Area2D


const RANGE := 2
const EXPLOSION_SCENE = preload("res://scenes/explosion.tscn")


func expand() -> void:
	var origin = $"../TileMapLayer".local_to_map(position)
	var directions = [
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.RIGHT
	]

	for direction in directions:
		expand_explosion(origin, direction)


func expand_explosion(origin: Vector2, direction: Vector2) -> void:
	for i in range(RANGE):
		var cell := origin + direction * i
		if is_cell_blocked(cell):
			break
		create_explosion_at(cell)


func is_cell_blocked(cell: Vector2i) -> bool:
	var source_id = $"../TileMapLayer".get_cell_source_id(cell)
	return source_id != 0


func create_explosion_at(cell: Vector2i) -> void:
	var new_explosion_position = $"../TileMapLayer".map_to_local(cell)
	var new_explosion = EXPLOSION_SCENE.instantiate()
	new_explosion.position = new_explosion_position
	get_parent().add_child(new_explosion)


func _on_timer_timeout() -> void:
	queue_free()
