extends KinematicBody

var path = []
var path_node = 0

var speed = 15
var health = 100
var dead = false
var attack = false
var state = "RUNNING"

const TURN_SPEED = 5
const DAMAGE = 10

onready var nav = get_parent()
onready var level = get_parent().get_parent()
onready var player = get_parent().get_parent().get_node("Player")
onready var anim_player = $Spacesuit/AnimationPlayer
onready var punch_anim = $Spacesuit/PunchAnimation
onready var eyes = $Eyes
onready var trigger_area = $TriggerRange
onready var attack_timer = $AttackTimer
onready var raycast = $RayCast
onready var move_timer = $Timer
onready var alive_collision = $AliveCollision
onready var dead_collision = $DeadCollision

#Drops
onready var assault_ammo = preload("res://Items/AssaultPickup.tscn")
onready var pistol_ammo = preload("res://Items/PistolAmmoPickup.tscn")
onready var grenades = preload("res://Items/GrenadePickup.tscn")
onready var health_pack = preload("res://Items/HealthPickup.tscn")

onready var drops = [assault_ammo,assault_ammo,assault_ammo,assault_ammo,pistol_ammo,pistol_ammo,pistol_ammo,pistol_ammo,grenades,health_pack,health_pack,"None","None","None","None","None","None","None","None"]

func _ready():
	pass

func _physics_process(delta):
	if not dead:
		if state == "RUNNING":
			anim_player.play("CharacterArmature|Run")
			if path_node < path.size():
				var direction = path[path_node] - global_transform.origin
				
				if direction.length() < 1:
					path_node += 1
				else:
					move_and_slide(direction.normalized() * speed, Vector3.UP)
		
		elif state == "ATTACK":
			pass
					
		face_player()
	if health <= 0:
		die()

func attack_animate():
	if anim_player.current_animation == "CharacterArmature|Run":
		anim_player.stop()
	if not anim_player.is_playing():
		#anim_player.play("CharacterArmature|Punch_Right")
		anim_player.play("punch_right_withdamage")

func damage_player():
	player.take_damage(DAMAGE)

func die():
	if not dead:
		var drop = drops[randi() % drops.size()]
		
		if !drop in ["None"]:
			var new_item = drop.instance()
			level.add_child(new_item)
			new_item.global_transform.origin = global_transform.origin
			
		
		anim_player.play("CharacterArmature|Death")
		dead = true
		attack_timer.stop()
		move_timer.stop()
		dead_collision.disabled = false
		alive_collision.disabled = true
		Global.enemies_killed += 1
		
	
func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0
	

func _on_Timer_timeout():
	if not dead and state == "RUNNING":
		move_to(player.global_transform.origin)

func face_player():
	eyes.look_at(player.global_transform.origin,Vector3.UP)
	rotate_y(deg2rad(eyes.rotation.y * TURN_SPEED))
	
func _on_TriggerRange_body_exited(body):
	if body.is_in_group("Player") and not dead:
		state = "RUNNING"
		attack_timer.stop()
		move_timer.start()

func _on_TriggerRange_body_entered(body):
	if body.is_in_group("Player") and not dead:
		state = "ATTACK"
		move_timer.stop()
		
		if attack_timer.time_left == 0:
			attack_timer.start()
			
		
func _on_AttackTimer_timeout():
	if raycast.is_colliding() and not dead:
		var hit = raycast.get_collider()
		
		
		if hit.is_in_group("Player"):
			anim_player.play("punch_right_withdamage")
		else:
			anim_player.stop()
