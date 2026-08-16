extends Node2D


func explode() -> void:
	var explosion := preload("res://scenes/explosion.tscn")
	var explosion_instance := explosion.instantiate()
	explosion_instance.global_position = global_position
	get_parent().add_child(explosion_instance)
	explosion_instance.expand()


func _on_timer_timeout() -> void:
	explode()
	queue_free()
