extends Spatial

onready var grenade = preload("res://ModelScenes/Grenade.tscn")

var power = 500
var can_shoot = true
var hud
var anim_player_fire
onready var animation_player = $AnimationPlayer

func _ready():
	hud = get_parent().get_parent().get_parent().get_parent().get_node("HUD")
	anim_player_fire = get_parent().get_parent().get_parent().get_parent().get_node("GrenadeAnim")
	animation_player.play("ReloadReturn")
	$DummyGrenade.hide()
	
func reload():
	if (Input.is_action_just_pressed("reload") or (Global.launcher_ammo["in_gun"] == 0 and Global.launcher_ammo["total"] != 0)) and Global.launcher_ammo["total"] != 0:
		var reload_sum = Global.launcher_ammo["max"] - Global.launcher_ammo["in_gun"]
		
		if reload_sum > Global.launcher_ammo["total"]:
			Global.launcher_ammo["in_gun"] = Global.launcher_ammo["total"]
			Global.launcher_ammo["total"] = 0
			
			if reload_sum != 0:
				reload_anim()

		else:
			if reload_sum != 0:
				reload_anim()
			Global.launcher_ammo["in_gun"] += reload_sum
			Global.launcher_ammo["total"] -= reload_sum
		
		yield(animation_player,"animation_finished")
		hud.update_ammo(Global.launcher_ammo["in_gun"],Global.launcher_ammo["total"],true)

func reload_anim():
	can_shoot = false
	animation_player.play("Reload")
	yield(animation_player,"animation_finished")
	animation_player.play("ReloadReturn")
	yield(animation_player,"animation_finished")
	can_shoot = true
				
		
func fire():
	if Input.is_action_just_pressed("fire") and can_shoot and Global.launcher_ammo["in_gun"] != 0:
		anim_player_fire.play("Fire")
		Global.launcher_ammo["in_gun"] -= 1
		hud.update_ammo(Global.launcher_ammo["in_gun"],Global.launcher_ammo["total"],true)
		var grenade_inst = grenade.instance()
		get_tree().get_root().add_child(grenade_inst)
		grenade_inst.global_transform.origin = $Muzzle.global_transform.origin
		grenade_inst.add_central_force(-self.global_transform.basis.z * power)

		$AudioStreamPlayer.play()
func _process(delta):
	reload()

