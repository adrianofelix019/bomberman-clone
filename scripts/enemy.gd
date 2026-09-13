extends CharacterBody2D


const SPEED := 40
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
	var target_position := tile_map.to_global(
		tile_map.map_to_local(target_cell)
	)
	
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
	return tile_map.get_cell_source_id(cell) == 0


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
		
		print(
			"Testando ",
			next_cell,
			" | source_id: ",
			tile_map.get_cell_source_id(next_cell),
			" | livre: ",
			is_cell_free(next_cell)
		)
		
		if is_cell_free(next_cell):
			target_cell = next_cell
			print(">>> NOVO TARGET: ", target_cell)
			return
	
	print("!!! NENHUMA CÉLULA LIVRE !!!")


func die() -> void:
	queue_free()
