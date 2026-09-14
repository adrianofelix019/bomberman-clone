extends Node2D


@onready var bomber_guy := $"../BomberGuy"


func explode() -> void:
	var explosion := preload("res://scenes/explosion.tscn")
	var explosion_instance := explosion.instantiate()
	explosion_instance.global_position = global_position
	get_parent().add_child(explosion_instance)
	explosion_instance.expand()


func _on_timer_timeout() -> void:
	explode()
	if is_instance_valid(bomber_guy):
		bomber_guy.bombs_coords.pop_front()
	queue_free()
