extends Spatial

var current_enemies = 0
var increment = 1
var dead_bodies = []
var wave_end = false
var display_timer = true
onready var nav = get_parent().get_node("Navigation")
onready var enemy = preload("res://Enemies/Pathfind.tscn")

onready var anim_player = $UIAnimate
onready var wave_info = $WaveUI/HBoxContainer/WaveInfoLabel
onready var wave_warning = $WaveUI/WaveWarningLabel
onready var wave_timer = $WaveTimer
onready var timer_label = $WaveUI/HBoxContainer/WaveTimerLabel
onready var player = get_parent().get_node("Player")

export var wave_interval : int
export var interval_increment : int

func _ready():
	wave_timer.wait_time = wave_interval
	wave_timer.start()
	wave_interval -= interval_increment

func _process(delta):
	if Global.enemies_killed == current_enemies:
		if wave_end:
			end_wave()
			wave_end = false
		
		if display_timer:
			wave_info.text = "Time until next wave: "
			timer_label.visible = true
			timer_label.text = str(wave_timer.time_left).pad_decimals(2)
		
	else:
		timer_label.visible = false
		wave_info.text = "Enemies left: " + str(current_enemies-Global.enemies_killed)

func start_wave():
	$AudioStreamPlayer3D.play()
	$WaveUI/HBoxContainer.alignment = BoxContainer.ALIGN_CENTER
	wave_end = true
	Global.wave_no += 1
	Global.enemies_killed = 0
	current_enemies += increment
	increment += 1
	
	wave_warning.text = "Wave " + str(Global.wave_no) +" started"
	anim_player.play("ShowWaveWarning")
	
	for i in range(current_enemies):
		var new_enemy = enemy.instance()
		nav.add_child(new_enemy)
		new_enemy.global_transform.origin = global_transform.origin
		var t = Timer.new()
		t.set_wait_time(0.5)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		t.queue_free()
		
func end_wave():
	display_timer = false
	wave_info.text = "Enemies left: 0"	
	Global.score += Global.wave_no
	Global.score += player.health/10
	var t = Timer.new()
	t.set_wait_time(3)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()

	
	for child in nav.get_children():
		if child.is_in_group("Enemy"):
			child.queue_free()
	
	wave_timer.wait_time = wave_interval
	wave_timer.start()
	display_timer = true
	$WaveUI/HBoxContainer.alignment = BoxContainer.ALIGN_BEGIN
	
	if wave_interval != 0:
		wave_interval -= interval_increment


func _on_WaveTimer_timeout():
	start_wave()
