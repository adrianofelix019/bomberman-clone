extends Node2D


@onready var tile_map: TileMapLayer = $TileMapLayer
var bomber_guy_scene := preload("res://scenes/bomber_guy.tscn")
var enemy_scene := preload("res://scenes/enemy.tscn")


func _ready() -> void:
	spawn_bomber_guy()
	spawn_enemy()


func spawn_bomber_guy() -> void:
	var bomber_guy := bomber_guy_scene.instantiate()

	var first_cell := Vector2i(1, 1)

	bomber_guy.global_position = tile_map.to_global(
		tile_map.map_to_local(first_cell)
	)

	add_child(bomber_guy)


func spawn_enemy() -> void:
	var enemy: CharacterBody2D = enemy_scene.instantiate()
	var random_cell := Vector2i(3, 1)
	enemy.global_position = tile_map.to_global(
		tile_map.map_to_local(random_cell)
	)
	
	var local_position := tile_map.map_to_local(random_cell)
	var _global_position := tile_map.to_global(local_position)
	
	add_child(enemy)
