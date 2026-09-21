extends CharacterBody2D

const SPEED := 20

@onready var tile_map: TileMapLayer = $"../TileMapLayer"
@onready var player: CharacterBody2D = $"../BomberGuy"

var current_cell: Vector2i
var target_cell: Vector2i


func _ready():
	current_cell = tile_map.local_to_map(
		tile_map.to_local(global_position)
	)

	target_cell = current_cell


func _physics_process(_delta):
	if current_cell == target_cell:
		target_cell = choose_next_cell()

	if target_cell != current_cell:
		var target_position := tile_map.to_global(
			tile_map.map_to_local(target_cell)
		)

		velocity = global_position.direction_to(target_position) * SPEED

		move_and_slide()

		if global_position.distance_to(target_position) < 1.0:
			global_position = target_position
			current_cell = target_cell
			velocity = Vector2.ZERO


func choose_next_cell() -> Vector2i:
	if is_instance_valid(player):
		Vector2i.ZERO
	
	var player_cell := tile_map.local_to_map(
		tile_map.to_local(player.global_position)
	)
	
	var path := find_path(current_cell, player_cell)
	
	if path.size() > 1:
		return path[1]
	
	return current_cell
	#var possible_cells := [
		#current_cell + Vector2i.RIGHT,
		#current_cell + Vector2i.LEFT,
		#current_cell + Vector2i.UP,
		#current_cell + Vector2i.DOWN
	#]
	#
	#var player_cell := tile_map.local_to_map(
		#tile_map.to_local(player.global_position)
	#)
	#
	#var best_cell := current_cell
	#var best_distance := INF
	#
	#for cell: Vector2i in possible_cells:
		#if not is_cell_free(cell):
			#continue
		#
		#var distance := cell.distance_to(player_cell)
		#
		#if distance < best_distance:
			#best_distance = distance
			#best_cell = cell
	#
	#return best_cell


func find_path(start: Vector2i, goal: Vector2i) -> Array[Vector2i]:
	var queue: Array[Vector2i] = [start]
	
	var came_from := {}
	came_from[start] = start
	
	var directions := [
		Vector2i.RIGHT,
		Vector2i.LEFT,
		Vector2i.UP,
		Vector2i.DOWN
	]
	
	while not queue.is_empty():
		var current: Vector2i = queue.pop_front()
		
		if current == goal:
			break
		
		for direction in directions:
			var next: Vector2i = current + direction
			
			if next in came_from:
				continue
			
			if not is_cell_free(next):
				continue
			
			came_from[next] = current
			queue.append(next)
	
	if goal not in came_from:
		return []
	
	var path: Array[Vector2i] = []
	var path_cell := goal
	
	while path_cell != start:
		path.push_front(path_cell)
		path_cell = came_from[path_cell]
	
	path.push_front(start)
	
	return path


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


func die() -> void:
	queue_free()
