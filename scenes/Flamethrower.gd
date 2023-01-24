extends Spatial

var damage = 6
var max_heat = 100
var heat_step = 2
var heat = 0
var cooldown_step = 2

func fire():
	if Input.is_action_just_pressed("fire"):
		if heat != max_heat:
			$Timer.start()
			$CooldownTimer.stop()
			$Particles.emitting = true
			$Sound.play()
	elif Input.is_action_just_released("fire") or heat == max_heat:
		$Timer.stop()
		$Particles.emitting = false
	
	if Input.is_action_just_released("fire"):
		$CooldownTimer.start()
	
	
func _on_Timer_timeout():
	var enemies = $Hitbox.get_overlapping_bodies()
	if heat < max_heat:
		heat += heat_step
		
		if heat >= max_heat:
			heat = max_heat
			$CooldownTimer.wait_time = 5
		
	
	for e in enemies:
		if e.is_in_group("Enemy"):
			e.health -= damage


func _on_CooldownTimer_timeout():
	$CooldownTimer.wait_time = 0.2
	if heat > 0:
		heat -= cooldown_step
		
		if heat < 0:
			heat = 0
