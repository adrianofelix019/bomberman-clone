extends Area2D


const RANGE := 2
const EXPLOSION_SCENE = preload("res://scenes/explosion.tscn")

@onready var tile_map: GameMap = $"../TileMapLayer"


func expand() -> void:
	var origin = tile_map.local_to_map(position)
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
		if tile_map.destroy_breakable_block(cell):
			break


func is_cell_blocked(cell: Vector2i) -> bool:
	var source_id = tile_map.get_cell_source_id(cell)
	return source_id == 1


func create_explosion_at(cell: Vector2i) -> void:
	var new_explosion_position = tile_map.map_to_local(cell)
	var new_explosion = EXPLOSION_SCENE.instantiate()
	new_explosion.position = new_explosion_position
	get_parent().add_child(new_explosion)


func _on_timer_timeout() -> void:
	if is_instance_valid($"../BomberGuy"):
		$"../BomberGuy".bombs_coords.pop_front()
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.die()
