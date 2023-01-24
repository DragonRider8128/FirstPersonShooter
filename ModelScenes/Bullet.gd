extends RigidBody

onready var raycast = $RayCast
onready var blood_splatter = preload("res://scenes/BloodSplatter.tscn")
onready var b_decal = preload("res://ModelScenes/BulletDecal.tscn")

var shoot = false

const DAMAGE = 45
const SPEED = 40


func _ready():
	set_as_toplevel(true)

func bullet_hole():
	if raycast.is_colliding():
		if not raycast.get_collider.is_in_group("transparent") and not raycast.get_collider.is_in_group("Player"):	
			var b = b_decal.instance()
			raycast.get_collider().add_child(b)
			b.global_transform.origin = raycast.get_collision_point()
			b.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.UP)


func _physics_process(delta):
	if shoot:
		apply_impulse(transform.basis.z,-transform.basis.z*SPEED)
		bullet_hole()
		shoot = false
		
func _on_Hitbox_body_entered(body):
	if body.is_in_group("Enemy"):
		var b = blood_splatter.instance()
		b.global_transform.origin = raycast.get_collision_point()
		get_tree().get_root().add_child(b)
		body.health -= DAMAGE
	queue_free()
