extends CharacterBody2D


const SPEED := 20
@onready var tile_map: TileMapLayer = $"../TileMapLayer"
var current_cell: Vector2i
var target_cell: Vector2i


func _ready() -> void:
	current_cell = tile_map.local_to_map(
		tile_map.to_local(global_position)
	)
	target_cell = current_cell
	choose_next_cell()


func _physics_process(_delta: float) -> void:
	var target_position := get_target_position()
	
	if not is_cell_free(target_cell):
		target_cell = current_cell
		choose_next_cell()
	
	if global_position.distance_to(target_position) < 1.0:
		current_cell = target_cell
		choose_next_cell()

	target_position = tile_map.to_global(
		tile_map.map_to_local(target_cell)
	)

	var direction := global_position.direction_to(target_position)
	velocity = direction * SPEED
	move_and_slide()


func is_cell_free(cell: Vector2i) -> bool:
	if tile_map.get_cell_source_id(cell) != 0:
		return false
	
	for bomb in get_tree().get_nodes_in_group("bombs"):
		var bomb_cell := tile_map.local_to_map(
			tile_map.to_local(bomb.global_position)
		)

		if bomb_cell == cell:
			return false
	
	return true


func choose_next_cell() -> void:
	var directions := [
		Vector2i.RIGHT,
		Vector2i.LEFT,
		Vector2i.UP,
		Vector2i.DOWN
	]
	
	directions.shuffle()
	
	for direction: Vector2i in directions:
		var next_cell := current_cell + direction
		
		if is_cell_free(next_cell):
			target_cell = next_cell
			return


func get_target_position() -> Vector2:
	var local_position := tile_map.map_to_local(target_cell)
	return tile_map.to_global(local_position)


func die() -> void:
	queue_free()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.die()
