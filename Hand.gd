extends Spatial

var mouse_mov
var sway_threshold = 5
var sway_lerp = 5
var sway = true

export var sway_left : Vector3
export var sway_right : Vector3
export var sway_normal : Vector3

export var normal_position : Vector3
export var ads_position : Vector3
export var normal_rotation : Vector3
export var ads_rotation : Vector3
const ADS_LERP = 20


func _input(event):
	if event is InputEventMouseMotion:
		mouse_mov = -event.relative.x
		sway_threshold = 5
	elif event is InputEventJoypadMotion:
		var controller_move = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
		mouse_mov = -controller_move
		sway_threshold = 0.1

func _process(delta):
	if mouse_mov != null and sway:
		if mouse_mov > sway_threshold:
			rotation = rotation.linear_interpolate(sway_left,sway_lerp*delta)
		elif mouse_mov < -sway_threshold:
			rotation = rotation.linear_interpolate(sway_right,sway_lerp*delta)
		else:
			rotation = rotation.linear_interpolate(sway_normal,sway_lerp*delta)
	
