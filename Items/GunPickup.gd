extends StaticBody

onready var prompt_anim = $PickupPrompt/AnimationPlayer
export (String, "Assault", "Pistol", "Launcher", "Hammer","Flamethrower") var weapon

var can_pickup = false
var player
var picked_up = false
var gun_object

func _process(delta):
	if can_pickup:
		if Input.is_action_just_pressed("interact"):
			if weapon == "Assault" and not player.assault_unlocked:
				player.assault_unlocked = true
				picked_up = true
				gun_object = player.assault
					
			elif weapon == "Pistol" and not player.pistol_unlocked:
				player.pistol_unlocked = true
				picked_up = true
				gun_object = player.pistol
				
			elif weapon == "Launcher" and not player.launcher_unlocked:
				player.launcher_unlocked = true
				picked_up = true
				gun_object = player.grenade_launcher
				
			elif weapon == "Hammer" and not player.hammer_unlocked:
				player.hammer_unlocked = true
				picked_up = true
				gun_object = player.hammer
				
			elif weapon == "Flamethrower" and not player.flamethrower_unlocked:
				player.flamethrower_unlocked = true
				picked_up = true
				gun_object = player.flamethrower
			
			if picked_up:
				player.update_inventory()
				player.weapon_index = player.inventory.find(gun_object,0)
				player.hand_anim.play("Draw")
				player.hud_ammo_update()
				prompt_anim.play("FadeOut")
				queue_free()

func _on_Range_body_entered(body):
	if body.is_in_group("Player"):
		can_pickup = true
		player = body
		prompt_anim.play("FadeIn")

func _on_Range_body_exited(body):
	if body.is_in_group("Player"):
		can_pickup = false
		prompt_anim.play("FadeOut")
