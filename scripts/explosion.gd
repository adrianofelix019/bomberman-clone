extends Area2D


const RANGE := 1
const EXPLOSION_SCENE = preload("res://scenes/explosion.tscn")
const BREAKABLE_SOURCE_ID = 3

@onready var tile_map: GameMap = $"../TileMapLayer"
@onready var sprite: Sprite2D = $Sprite

@export var center_texture: Texture2D
@export var horizontal_texture: Texture2D
@export var tip_texture: Texture2D


func expand() -> void:
	var origin = tile_map.local_to_map(position)
	var explosion_cells := tile_map.get_explosion_cells(origin)
	
	var visible_cells: Array[Vector2i] = []
	
	for cell in explosion_cells:
		var tile_source_id := tile_map.get_cell_source_id(cell)
		
		if tile_source_id == BREAKABLE_SOURCE_ID:
			tile_map.destroy_breakable_block(cell)
			continue
		
		visible_cells.append(cell)
	
	for cell in visible_cells:
		create_explosion_at(cell, origin, visible_cells)


func create_explosion_at(
	cell: Vector2i,
	origin: Vector2i,
	visible_cells: Array[Vector2i]
) -> void:
	var new_explosion = EXPLOSION_SCENE.instantiate()
	new_explosion.position = tile_map.map_to_local(cell)
	
	var current_sprite: Sprite2D = new_explosion.get_node("Sprite")
	
	if cell == origin:
		current_sprite.texture = center_texture
	else:
		var direction := Vector2i(
			sign(cell.x - origin.x),
			sign(cell.y - origin.y)
		)
		var next_cell := cell + direction
		var is_tip := not visible_cells.has(next_cell)
		
		if is_tip:
			current_sprite.texture = tip_texture
			current_sprite.rotation = Vector2(direction).angle()
		else:
			current_sprite.texture = horizontal_texture
	
		if direction.y != 0:
			current_sprite.rotation = PI / 2.0
	
	get_parent().add_child(new_explosion)


func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.die()
