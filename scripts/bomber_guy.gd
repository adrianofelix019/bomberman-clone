extends CharacterBody2D


signal player_moved


const SPEED := 40.0
const PLAYER_HALF_WIDTH := 4.0
const PLAYER_HALF_HEIGHT := 6.5


@onready var tile_map: TileMapLayer = $"../TileMapLayer"


var bomb_scene := preload("res://scenes/bomb.tscn")

var current_player_cell: Vector2i
var bombs_coords: Array[Vector2i] = []


func _ready() -> void:
	current_player_cell = get_player_cell()


func _physics_process(delta: float) -> void:
	move(delta)


func move(delta: float) -> void:
	var direction := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	velocity = direction * SPEED

	handle_bomb_collision(direction, delta)
	move_and_slide()
	update_player_cell()


func update_player_cell() -> void:
	var new_player_cell := get_player_cell()

	if new_player_cell == current_player_cell:
		return

	current_player_cell = new_player_cell
	player_moved.emit()


func get_player_cell() -> Vector2i:
	var tile_map_position := tile_map.to_local(global_position)

	return tile_map.local_to_map(tile_map_position)


func handle_bomb_collision(direction: Vector2, delta: float) -> void:
	if direction == Vector2.ZERO:
		return

	var blocked_x := false
	var blocked_y := false

	if direction.x != 0:
		var target_x := current_player_cell

		if direction.x > 0:
			target_x.x += 1
		else:
			target_x.x -= 1

		blocked_x = is_cell_blocked(target_x)

	if direction.y != 0:
		var target_y := current_player_cell

		if direction.y > 0:
			target_y.y += 1
		else:
			target_y.y -= 1

		blocked_y = is_cell_blocked(target_y)
	
	var next_position := global_position + velocity * delta

	if blocked_x:
		if direction.x > 0:
			var limit := get_cell_right_edge() - PLAYER_HALF_WIDTH
			
			if next_position.x > limit:
				velocity.x = (limit - global_position.x) / delta
		elif direction.x < 0:
			var limit := get_cell_left_edge() + PLAYER_HALF_WIDTH
			
			if next_position.x < limit:
				velocity.x = (limit - global_position.x) / delta

	if blocked_y:
		if direction.y > 0:
			var limit := get_cell_bottom_edge() - PLAYER_HALF_HEIGHT
			
			if next_position.y > limit:
				velocity.y = (limit - global_position.y) / delta
		elif direction.y < 0:
			var limit := get_cell_top_edge() + PLAYER_HALF_HEIGHT
			
			if next_position.y < limit:
				velocity.y = (limit - global_position.y) / delta


func is_cell_blocked(cell: Vector2i) -> bool:
	return cell in bombs_coords


func place_bomb() -> void:
	var bomb_cell := get_player_cell()

	if count_bombs() >= 1:
		return

	var bomb := bomb_scene.instantiate()

	bomb.global_position = tile_map.to_global(
		tile_map.map_to_local(bomb_cell)
	)

	bombs_coords.append(bomb_cell)

	get_parent().add_child(bomb)


func count_bombs() -> int:
	return get_tree().get_nodes_in_group("bombs").size()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("place_bomb"):
		place_bomb()


func get_current_cell_center() -> Vector2:
	return tile_map.to_global(
		tile_map.map_to_local(current_player_cell)
	)


func get_cell_right_edge() -> float:
	return get_current_cell_center().x + 8


func get_cell_left_edge() -> float:
	return get_current_cell_center().x - 8


func get_cell_top_edge() -> float:
	return get_current_cell_center().y - 8


func get_cell_bottom_edge() -> float:
	return get_current_cell_center().y + 8


func die():
	print("You died!")
	set_physics_process(false)
	queue_free()
