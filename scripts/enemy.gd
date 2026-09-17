extends CharacterBody2D


const SPEED := 20
const CHASE_MIN_TIME := 3.0
const CHASE_MAX_TIME := 5.0
const RANDOM_MIN_TIME := 2.0
const RANDOM_MAX_TIME := 4.0

@onready var tile_map: TileMapLayer = $"../TileMapLayer"
var current_cell: Vector2i
var target_cell: Vector2i
var is_chasing := false
var state_timer := 0.0

func _ready() -> void:
	current_cell = tile_map.local_to_map(
		tile_map.to_local(global_position)
	)
	
	target_cell = current_cell
	
	state_timer = randf_range(
		RANDOM_MIN_TIME,
		RANDOM_MAX_TIME
	)
	
	choose_next_cell()


func _physics_process(delta: float) -> void:
	state_timer -= delta
	
	if state_timer <= 0:
		change_state()
	
	var target_position := get_target_position()
	
	if not is_cell_free(target_cell):
		target_cell = current_cell
		
		if is_chasing:
			choose_chase_cell()
		else:
			choose_next_cell()
	
	if global_position.distance_to(target_position) < 1.0:
		current_cell = target_cell
		if is_chasing:
			choose_chase_cell()
		else:
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


func choose_chase_cell() -> void:
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	
	if player == null:
		return
	
	var player_cell := tile_map.local_to_map(
		tile_map.to_local(player.global_position)
	)
	
	var directions := [
		Vector2i.RIGHT,
		Vector2i.LEFT,
		Vector2i.UP,
		Vector2i.DOWN
	]
	
	var best_cell := current_cell
	var best_distance := INF
	
	for direction: Vector2i in directions:
		var next_cell = current_cell + direction
		
		if not is_cell_free(next_cell):
			continue
		
		var distance := next_cell.distance_squared_to(player_cell)
		
		if distance < best_distance:
			best_distance = distance
			best_cell = next_cell
	target_cell = best_cell


func change_state() -> void:
	is_chasing = not is_chasing
	
	if is_chasing:
		state_timer = randf_range(
			CHASE_MIN_TIME,
			CHASE_MAX_TIME
		)
		choose_chase_cell()
	else:
		state_timer = randf_range(
			RANDOM_MIN_TIME,
			RANDOM_MAX_TIME
		)
		choose_next_cell()


func die() -> void:
	queue_free()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.die()
