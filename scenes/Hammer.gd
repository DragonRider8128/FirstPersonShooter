extends Spatial

var damage = 60
var hitbox
onready var blood_splatter = preload("res://scenes/BloodSplatter.tscn")

func _ready():
	$AnimationPlayer.play("Return")
	hitbox = get_parent().get_parent().get_parent().get_parent().get_node("Hitbox")

func attack():
	if Input.is_action_just_pressed("fire"):
		if not $AnimationPlayer.is_playing():
			$AnimationPlayer.play("Attack")
			$AnimationPlayer.queue("Return")
		if $AnimationPlayer.current_animation == "Attack":
			for body in hitbox.get_overlapping_bodies():
				if body.is_in_group("Enemy"):
					var b = blood_splatter.instance()
					b.global_transform.origin = body.get_node("Spawner").global_transform.origin
					get_tree().get_root().add_child(b)
					body.health -= damage
					$AudioStreamPlayer.play()
