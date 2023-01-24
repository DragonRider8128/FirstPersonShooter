extends MeshInstance

var deal_damage = false
var player
const DAMAGE = 25

func _process(delta):
	if deal_damage:
		if $Timer.time_left == 0:
			$Timer.start()
	else:
		$Timer.stop()

func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		deal_damage = true
		player = body

func _on_Area_body_exited(body):
	if body.is_in_group("Player"):
		deal_damage = false
		player = body

func _on_Timer_timeout():
	player.take_damage(DAMAGE)
