extends StaticBody

export (String, "Health", "Assault Ammo", "Pistol Ammo", "Grenade Launcher Ammo") var pickup_type
var can_pickup = false
var picked_up = false
var player
export(int) var addition = 50
var hud
onready var prompt_anim = $PickupPrompt/AnimationPlayer
	
	
func _process(delta):
	if can_pickup:
		hud = player.get_node("HUD")
		if Input.is_action_just_pressed("interact") and not picked_up:
			if pickup_type == "Health":
				
				if player.health == player.max_health:
					picked_up = false
				
				elif player.health + addition > player.max_health:
					player.health += (player.max_health - player.health)
					picked_up = true
					
				else:
					player.health += addition
					picked_up = true
				

					
			elif pickup_type == "Assault Ammo":
				player.assault_ammo["in_gun"] += addition
				
				if player.weapon == "assault":
					hud.update_ammo(player.assault_ammo["in_gun"],0,false)
				
				picked_up = true
			elif pickup_type == "Pistol Ammo":
				player.pistol_ammo["total"] += addition
				
				if player.weapon == "pistol":
					hud.update_ammo(player.pistol_ammo["in_gun"],player.pistol_ammo["total"],true)
				picked_up = true
			elif pickup_type == "Grenade Launcher Ammo":
				Global.launcher_ammo["total"] += addition
				
				if player.weapon == "launcher":
					hud.update_ammo(Global.launcher_ammo["in_gun"],Global.launcher_ammo["total"],true)
				picked_up = true
			
			if picked_up:
				hide()
				prompt_anim.play("FadeOut")
				$AudioStreamPlayer.play()
				yield(get_node("AudioStreamPlayer"),"finished")
				queue_free()
					


func _on_PickupRange_body_entered(body):
	if body.is_in_group("Player"):
		can_pickup = true
		player = body
		prompt_anim.play("FadeIn")


func _on_PickupRange_body_exited(body):
	if body.is_in_group("Player"):
		can_pickup = false
		prompt_anim.play("FadeOut")
