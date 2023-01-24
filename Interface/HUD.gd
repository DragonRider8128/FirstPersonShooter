extends Control

onready var ammo_label = $AmmoContainer/AmmoLabel
onready var ammo_title = $AmmoContainer/AmmoTitle
onready var flame_bar = $FlamethrowerHeat

onready var health_over = $HealthBar/HealthOver
onready var health_under = $HealthBar/HealthUnder
onready var damage_tween = $HealthBar/DamageTween

export (Color) var high_health = Color.green
export (Color) var medium_health = Color.orange
export (Color) var low_health = Color.red

func _ready():
	$OverheatIcon.hide()

func _process(delta):
	$ScoreText.text = "Score: " + str(Global.score)

func flash_damage():
	$DamageOverlay.visible = true
	$DamageAnim.play("DamageEffect")

func update_ammo(in_gun, total, reload):
	ammo_label.show()
	ammo_title.text = "Ammo"
	flame_bar.hide()
	if reload:
		ammo_label.text = str(in_gun) + "/" + str(total)
	else:
		ammo_label.text = str(in_gun)

func flamethrower_hud():
	ammo_label.hide()
	ammo_title.text = "Heat"
	flame_bar.show()

func update_heat(heat):
	flame_bar.value = heat
	if heat == 100 and get_parent().weapon == "flamethrower":
		$OverheatIcon.show()
		$AnimationPlayer.play("OverheatFlash2")
	else:
		$AnimationPlayer.stop()
		$OverheatIcon.hide()

func update_health(health):	
	health_over.value = health
	damage_tween.interpolate_property(health_under,"value",health_under.value,health,0.1,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	damage_tween.start()
	
	if health > health_over.max_value * 0.5:
		health_over.get("custom_styles/fg").bg_color = high_health
	elif health > health_over.max_value * 0.3:
		health_over.get("custom_styles/fg").bg_color = medium_health
	else:
		health_over.get("custom_styles/fg").bg_color = low_health
	
		
func health_start(max_health,health):
	health_over.max_value = max_health
	health_under.max_value = max_health
	health_over.value = health
	health_under.value = health
