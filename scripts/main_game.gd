extends Node2D


@onready var tile_map: TileMapLayer = $TileMapLayer
var enemy_cells: Array[Vector2i] = []
var player_cell := Vector2i(1, 1)

var bomber_guy_scene := preload("res://scenes/bomber_guy.tscn")
var enemy_scene := preload("res://scenes/enemy.tscn")
var bloodthirsty_scene := preload("res://scenes/bloodthirsty.tscn")

const ENEMY_COUNT := 5
const MIN_ENEMY_DISTANCE := 3


func _ready() -> void:
	spawn_bomber_guy()
	spawn_enemy()


func spawn_bomber_guy() -> void:
	var bomber_guy := bomber_guy_scene.instantiate()

	bomber_guy.global_position = tile_map.to_global(
		tile_map.map_to_local(player_cell)
	)

	add_child(bomber_guy)


func spawn_enemy() -> void:
	for enemy_count in ENEMY_COUNT:
		var enemy: CharacterBody2D = enemy_scene.instantiate()
		var random_cell := get_random_free_cell()
		
		enemy.global_position = tile_map.to_global(
			tile_map.map_to_local(random_cell)
		)
		
		var local_position := tile_map.map_to_local(random_cell)
		var _global_position := tile_map.to_global(local_position)
		
		add_child(enemy)
	spawn_bloodthirsty()


func spawn_bloodthirsty() -> void:
	var bloodthirsty: CharacterBody2D = bloodthirsty_scene.instantiate()
	var random_cell := get_random_free_cell()
	
	bloodthirsty.global_position = tile_map.to_global(
		tile_map.map_to_local(random_cell)
	)
	
	add_child(bloodthirsty)


func get_random_free_cell() -> Vector2i:
	var used_rect = tile_map.get_used_rect()
	var cell: Vector2i
	
	while true:
		var x := randi_range(
			used_rect.position.x,
			used_rect.end.x - 1
		)
		
		var y := randi_range(
			used_rect.position.y,
			used_rect.end.y - 1
		)
		
		cell = Vector2i(x, y)
		
		if tile_map.get_cell_source_id(cell) != 0:
			continue
		
		var distance = abs(cell.x - player_cell.x) + abs(cell.y - player_cell.y)
		
		if distance <= MIN_ENEMY_DISTANCE:
			continue
		
		if cell in enemy_cells:
			continue
		else:
			enemy_cells.append(cell)
			break

	return cell
