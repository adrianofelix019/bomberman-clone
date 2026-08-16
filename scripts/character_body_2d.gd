extends CharacterBody2D


const SPEED := Vector2(40, 40)
var bomb_tscn = preload("res://scenes/bomb.tscn")
var boombs_coords: Array[Vector2] = []


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)
	velocity = direction * SPEED
	move_and_slide()
	count_boombs()


func _input(_event: InputEvent) -> void:
	place_bomb()


func place_bomb() -> void:
	var boomb_coords = $"../TileMapLayer".local_to_map(position)
	
	if Input.is_action_just_pressed("place_bomb"):
		boombs_coords.append(boomb_coords)
		var bomb := bomb_tscn.instantiate()
		bomb.global_position = $"../TileMapLayer".map_to_local(boomb_coords)
		get_parent().add_child(bomb)


func count_boombs():
	get_parent().find_children("bomb")
