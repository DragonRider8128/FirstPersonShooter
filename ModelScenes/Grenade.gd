extends RigidBody

var damage = 100
onready var blast_timer = $BlastTimer
onready var radius = $BlastRadius
onready var particles = preload("res://Particles.tscn")


func explode():
	var particle_inst = particles.instance()
	get_tree().get_root().add_child(particle_inst)
	
	particle_inst.transform.origin = self.transform.origin
	particle_inst.emitting = true
		
	for body in radius.get_overlapping_bodies():
		if body.is_in_group("Enemy"):
			body.health -= damage
		
		if body is RigidBody:
			body.add_central_force((body.global_transform.origin - self.global_transform.origin).normalized() * 1300)
		
		if body.is_in_group("Player"):
			body.health -= 90
			
			
	queue_free()

func start_timer():
	blast_timer.start()

func _on_BlastTimer_timeout():
	explode()

func _on_Trigger_body_entered(body):
	explode()
