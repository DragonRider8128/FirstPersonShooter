extends KinematicBody

var sprint_speed = 26
var normal_speed = 20
var speed = normal_speed


var h_acceleration = 6
var air_acceleration = 2
var normal_acceleration = 6

var gravity = 20
var jump = 13
var full_contact = false


var mouse_sensitivity = 0.05

var direction = Vector3()
var h_velocity = Vector3()
var movement = Vector3()
var gravity_vec = Vector3()

var assault_damage = 20
const MAX_CAM_SHAKE = 0.2

onready var head = $Head
onready var ground_check = $GroundCheck
onready var camera = $Head/Camera
onready var sfx_player = $SFXPlayer
onready var b_timer = $BulletTimer

onready var gun_cast = $Head/Camera/GunCast
onready var assault_anim = $AssaultAnim
onready var b_decal = preload("res://ModelScenes/BulletDecal.tscn")
onready var bullet = preload("res://ModelScenes/Bullet.tscn")
onready var blood_splatter = preload("res://scenes/BloodSplatter.tscn")
var b_hole_place = true
var pistol_fire = true
onready var pistol_timer = $PistolTimer
onready var muzzle = $Head/Camera/Hand/Pistol/Muzzle

onready var pistol = $Head/Camera/Hand/Pistol
onready var assault = $Head/Camera/Hand/GAP_2DAE01_Adriaens_Naomi_Lowpoly
onready var pistol_anim = $Head/Camera/Hand/Pistol/AnimationPlayer
onready var hammer = $Head/Camera/Hand/Hammer
onready var flamethrower = $Head/Camera/Hand/Flamethrower
onready var grenade_launcher = $Head/Camera/Hand/GrenadeLauncher

onready var hud = $HUD
onready var launcher_icon = $HUD/LauncherIcon
onready var pistol_icon = $HUD/PistolIcon
onready var assault_icon = $HUD/AssaultIcon
onready var ammo_container = $HUD/AmmoContainer
onready var ammo_bg = $HUD/AmmoBG

onready var hand_anim = $HandAnim

var icons = [launcher_icon,pistol_icon,assault_icon]

var assault_ammo = {"in_gun" : 40}
var pistol_ammo = {"in_gun" : 6, "total" : 15, "max": 6}

export var assault_unlocked : bool
export var pistol_unlocked : bool
export var launcher_unlocked : bool
export var hammer_unlocked : bool
export var flamethrower_unlocked : bool

var inventory = []
var weapon = null
var weapon_index = 0
var can_fire = true
var can_reload = false

var health = 100
var max_health = 100

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	update_inventory()
	
	if weapon_index != null:
		hud_ammo_update()
	
	hud.health_start(max_health,health)

func take_damage(amount):
	hud.flash_damage()
	health -= amount

func die():
	get_tree().change_scene("res://TestLevel/TestLevel.tscn")
	Global.wave_no = 0
	Global.enemies_killed = 0
	Global.score = 0
	Global.launcher_ammo = {"in_gun" : 1, "total" : 1, "max" : 1}
	
func update_inventory():
	inventory = []
	
	if assault_unlocked:
		inventory.append(assault)
	if pistol_unlocked:
		inventory.append(pistol)
	if launcher_unlocked:
		inventory.append(grenade_launcher)
	if hammer_unlocked:
		inventory.append(hammer)
	if flamethrower_unlocked:
		inventory.append(flamethrower)
		
	if inventory.size() == 0:
		weapon_index = null

func assault_fire():
	if Input.is_action_pressed("fire") and assault_ammo["in_gun"] > 0:
		
		if not assault_anim.is_playing():
			assault_ammo["in_gun"] -= 1
			hud.update_ammo(assault_ammo["in_gun"],0,false)
			sfx_player.stream = load("res://SFX/ak47_trim_2.wav")
			
			if !sfx_player.playing:
				sfx_player.play()
			
			camera.translation = lerp(camera.translation, 
					Vector3(rand_range(MAX_CAM_SHAKE, -MAX_CAM_SHAKE), 
					rand_range(MAX_CAM_SHAKE, -MAX_CAM_SHAKE), 0), 0.5)
			if gun_cast.is_colliding():
				var target = gun_cast.get_collider()
				if target.is_in_group("Enemy"):
					var b = blood_splatter.instance()
					b.global_transform.origin = gun_cast.get_collision_point()
					get_tree().get_root().add_child(b)
					target.health -= assault_damage
					
		assault_anim.play("AssaultFire")
		
	else:
		assault_anim.stop()
		sfx_player.stop()

func pistol_fire():
	if Input.is_action_just_pressed("fire"):
		if pistol_ammo["in_gun"] != 0:
			if pistol_fire:
				pistol_ammo["in_gun"] -= 1
				hud.update_ammo(pistol_ammo["in_gun"],pistol_ammo["total"],true)
				
				pistol_anim.play("PistolArmature|Fire")
				sfx_player.stream = load("res://SFX/pistol.wav")
				sfx_player.play()
				pistol_fire = false
				pistol_timer.start()
				var b = bullet.instance()
				muzzle.add_child(b)
				b.look_at(gun_cast.get_collision_point(),Vector3.UP)
				b.shoot = true


func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))
	
	if event is InputEventMouseButton or event is InputEventJoypadButton:
		if event.is_pressed() and weapon_index != null:
			if event.button_index == BUTTON_WHEEL_UP:
				if weapon_index + 1 < inventory.size():
					weapon_index += 1
				else:
					weapon_index = 0
				hand_anim.play("Draw")
				

				
			elif event.button_index == BUTTON_WHEEL_DOWN:
				if weapon_index+1 > 1:
					weapon_index -= 1
				else:
					weapon_index = inventory.size()-1
				hand_anim.play("Draw")
			
			hud_ammo_update()
					
			

func reload():
	var weapon_ammo
	var animation_player
	var anim_name
	
	if weapon == "pistol":
		weapon_ammo = pistol_ammo
		animation_player = pistol.get_node("AnimationPlayer")
		
	if (Input.is_action_just_pressed("reload") or (weapon_ammo["in_gun"] == 0 and weapon_ammo["total"] != 0)) and weapon_ammo["total"] != 0:
		
		var reload_sum = weapon_ammo["max"] - weapon_ammo["in_gun"]
		
		
		if reload_sum > weapon_ammo["total"]:
			weapon_ammo["in_gun"] += weapon_ammo["total"]
			weapon_ammo["total"] = 0
			if reload_sum != 0:
				if weapon == "pistol":
					can_fire = false
					animation_player.play("Reload")
					yield(animation_player,"animation_finished")
					animation_player.play("Reload_Return")
					yield(animation_player,"animation_finished")
					can_fire = true

		else:
			weapon_ammo["in_gun"] += reload_sum
			weapon_ammo["total"] -= reload_sum
			if reload_sum != 0:
				if weapon == "pistol":		
					can_fire = false
					animation_player.play("Reload")
					yield(animation_player,"animation_finished")
					animation_player.play("Reload_Return")
					yield(animation_player,"animation_finished")
					can_fire = true
		
		
		#yield(animation_player, "animation_finished")
		hud.update_ammo(weapon_ammo["in_gun"],weapon_ammo["total"],true)
		
func bullet_hole():
	if Input.is_action_pressed("fire") and b_hole_place and gun_cast.is_colliding() and not gun_cast.get_collider().is_in_group("transparent") and not gun_cast.get_collider().is_in_group("Player"):
		b_hole_place = false
		
		b_timer.start()
		var b = b_decal.instance()
		gun_cast.get_collider().add_child(b)
		b.global_transform.origin = gun_cast.get_collision_point()
		b.look_at(gun_cast.get_collision_point() + gun_cast.get_collision_normal(), Vector3.UP)
	
		
func _physics_process(delta):
	hud.update_health(health)
	
	
	if health <= max_health * 0.3 and health > 0:
		$HealthAnim.play("PulseSound")
		hud.flash_damage()
	else:
		$HealthAnim.stop()
		hud.get_node("DamageAnim").stop()
		hud.get_node("DamageOverlay").visible = false
		
	if health <= 0:
		die()

	weapons()
	apply_controller_rotation()	

	
	if weapon == "pistol":
		if can_fire:
			fire()
	else:
		fire()
	if can_reload:
		reload()
	
	if weapon != null:
		if (weapon == "assault" and assault_ammo["in_gun"] != 0):
			bullet_hole()


	direction = Vector3()
	
	full_contact = ground_check.is_colliding()
	
	if Input.is_action_pressed("sprint"):
		speed = sprint_speed
	elif Input.is_action_just_released("sprint"):
		speed = normal_speed
		
	if not is_on_floor():
		gravity_vec += Vector3.DOWN * gravity * delta
		h_acceleration = air_acceleration
	elif is_on_floor() and full_contact:
		gravity_vec = -get_floor_normal() * gravity
		h_acceleration = normal_acceleration
	else:
		gravity_vec = -get_floor_normal()
		h_acceleration = normal_acceleration
		
	if Input.is_action_just_pressed("jump") and (is_on_floor() or ground_check.is_colliding()):
		gravity_vec = Vector3.UP * jump
	
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	elif Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	
	direction = direction.normalized()
	h_velocity = h_velocity.linear_interpolate(direction * speed, h_acceleration * delta)
	movement.z = h_velocity.z + gravity_vec.z
	movement.x = h_velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
	
	move_and_slide(movement, Vector3.UP)

func apply_controller_rotation():
	var controller_sensitivity = 1
	var axis_vector = Vector2.ZERO
	axis_vector.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	axis_vector.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	
	if InputEventJoypadMotion:
		rotate_y(deg2rad(-axis_vector.x)*controller_sensitivity)
		head.rotate_x(deg2rad(-axis_vector.y)*controller_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))
		
func fire():
	if weapon_index != null:
		if weapon == "assault":
			assault_fire()
		elif weapon == "pistol":
			pistol_fire()
		elif weapon == "launcher":
			grenade_launcher.fire()
		elif weapon == "hammer":
			hammer.attack()
		elif weapon == "flamethrower":
			flamethrower.fire()
			
		if flamethrower in inventory:
			hud.update_heat(flamethrower.heat)

func hud_ammo_update():
	if inventory[weapon_index] == assault:
		hud.update_ammo(assault_ammo["in_gun"],0,false)
	elif inventory[weapon_index] == pistol:
		hud.update_ammo(pistol_ammo["in_gun"],pistol_ammo["total"],true)
	elif inventory[weapon_index] == grenade_launcher:
		hud.update_ammo(Global.launcher_ammo["in_gun"],Global.launcher_ammo["total"],true)
	elif inventory[weapon_index] == flamethrower:
		hud.flamethrower_hud()
	
	
func weapons():
	
	if Input.is_action_just_pressed("weapon1"):
		if inventory.size() >= 1:
			weapon_index = 0
			hand_anim.play("Draw")
			hud_ammo_update()
	elif Input.is_action_just_pressed("weapon2"):
		if inventory.size() >= 2:
			weapon_index = 1
			hand_anim.play("Draw")
			hud_ammo_update()
	elif Input.is_action_just_pressed("weapon3"):
		if inventory.size() >= 3:
			weapon_index = 2
			hand_anim.play("Draw")
			hud_ammo_update()
	elif Input.is_action_just_pressed("weapon4"):
		if inventory.size() >= 4:
			weapon_index = 3
			hand_anim.play("Draw")
			hud_ammo_update()
			
	elif Input.is_action_just_pressed("weapon5"):
		if inventory.size() >= 5:
			weapon_index = 4
			hand_anim.play("Draw")
			hud_ammo_update()
	
	if weapon_index != null:
		for weapon in inventory:
			weapon.visible = false
		
		inventory[weapon_index].visible = true
		
		assault_icon.visible = false
		pistol_icon.visible = false
		launcher_icon.visible = false
		
		ammo_bg.visible = true
		ammo_container.visible = true
		
		if inventory[weapon_index] == assault:
			can_reload = false
			weapon = "assault"
			assault_icon.visible = true
			hud.get_node("AmmoContainer/AmmoLabel").visible = true
			hud.get_node("AmmoContainer/AmmoTitle").visible = true
		elif inventory[weapon_index] == pistol:
			can_reload = true
			weapon = "pistol"
			pistol_icon.visible = true
			hud.get_node("AmmoContainer/AmmoLabel").visible = true
			hud.get_node("AmmoContainer/AmmoTitle").visible = true
		elif inventory[weapon_index] == grenade_launcher:
			can_reload = false
			weapon = "launcher"
			launcher_icon.visible = true
			hud.get_node("AmmoContainer/AmmoLabel").visible = true
			hud.get_node("AmmoContainer/AmmoTitle").visible = true
		elif inventory[weapon_index] == hammer:
			can_reload = false
			weapon = "hammer"
			hud.get_node("AmmoContainer/AmmoLabel").visible = false
			hud.get_node("AmmoContainer/AmmoTitle").visible = false
			hud.get_node("FlamethrowerHeat").visible = false
		elif inventory[weapon_index] == flamethrower:
			can_reload = false
			weapon = "flamethrower"
			hud.get_node("AmmoContainer/AmmoLabel").visible = false
			hud.get_node("AmmoContainer/AmmoTitle").visible = true
			hud.flame_bar.visible = true
			
		if inventory[weapon_index] != flamethrower:
			hud.flame_bar.visible = false
		
	else:
		ammo_bg.visible = false
		ammo_container.visible = false
		assault_icon.visible = false
		pistol_icon.visible = false
		launcher_icon.visible = false
		hud.flame_bar.visible = false
 
func _on_BulletTimer_timeout():
	b_hole_place = true

func _on_PistolTimer_timeout():
	pistol_fire = true
