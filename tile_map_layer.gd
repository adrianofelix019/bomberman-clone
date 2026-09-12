class_name GameMap
extends TileMapLayer

const BREAKABLE_SOURCE_ID := 3
const GROUND_SOURCE_ID := 0
const BREAKABLE_TILE := Vector2i(0, 0)
const UNBREAKABLE_TILES_SOURCE_ID := [0, 1]
const MAP_WIDTH := 18
const MAP_HEIGHT := 16
const BREAK_AMOUNT := 35


func _ready() -> void:
	generate_breakable_blocks()


func generate_breakable_blocks() -> void:
	var possible_cells: Array[Vector2i] = []
	
	for y in range(1, MAP_HEIGHT - 1):
		for x in range(1, MAP_WIDTH - 1):
			var cell := Vector2i(x, y)
			
			if get_cell_source_id(cell) == 1:
				continue
			
			if is_player_spawn_area(cell):
				continue

			possible_cells.append(cell)
	possible_cells.shuffle()
	
	var amount = min(BREAK_AMOUNT, possible_cells.size())
	for i in range(amount):
		set_cell(possible_cells[i], BREAKABLE_SOURCE_ID, BREAKABLE_TILE)


func is_player_spawn_area(cell: Vector2i) -> bool:
	var spawn := Vector2i(1, 1)
	
	return (
		cell == spawn
		or cell == spawn + Vector2i.RIGHT
		or cell == spawn + Vector2i.LEFT
	)


func destroy_breakable_block(cell: Vector2i) -> bool:
	var source_id := get_cell_source_id(cell)
	if source_id in UNBREAKABLE_TILES_SOURCE_ID:
		return false
	set_cell(
		cell,
		GROUND_SOURCE_ID,
		Vector2i.ZERO
	)
	return true
