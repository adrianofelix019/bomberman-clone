extends Area2D


const RANGE := 2
const EXPLOSION_SCENE = preload("res://scenes/explosion.tscn")
const BREAKABLE_SOURCE_ID = 3

@onready var tile_map: GameMap = $"../TileMapLayer"


func expand() -> void:
	var origin = tile_map.local_to_map(position)
	var explosion_cells := tile_map.get_explosion_cells(origin)
	
	for cell in explosion_cells:
		var tile_source_id := tile_map.get_cell_source_id(cell)
		
		if tile_source_id == BREAKABLE_SOURCE_ID:
			tile_map.destroy_breakable_block(cell)
			continue
		
		create_explosion_at(cell)


func create_explosion_at(cell: Vector2i) -> void:
	var new_explosion_position = tile_map.map_to_local(cell)
	var new_explosion = EXPLOSION_SCENE.instantiate()
	new_explosion.position = new_explosion_position
	get_parent().add_child(new_explosion)


func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.die()
