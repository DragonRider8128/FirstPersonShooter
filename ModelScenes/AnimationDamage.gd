extends Spatial

onready var main_enemy = get_parent()
var damaged = false

func damage():
	if not damaged:
		main_enemy.damage_player()
		damaged = true

func reset_punch():
	damaged = false
