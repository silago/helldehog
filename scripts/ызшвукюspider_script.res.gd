extends RigidBody2D

# points in the path
var points = []
var path   = []
const speed = 200
var player
var target = Vector2(0,0)
const velocity=120

func _fixed_process(delta):
	if target!=Vector2(0,0):
		process_jump(delta)
	if (target==get_pos()):
		target=Vector2(0,0)

func _ready():
	set_fixed_process(true)
	return
	set_fixed_process(false)
	#target = get_parent().get_node("Helldehog")
	get_node("sprite").set_scale(get_scale())
	get_node("shape").set_scale(get_scale())
	get_node("anim").play("walk")
	set_process(true)
	player = get_node("../../../Helldehog")
	#set_applied_force(Vector2(-500,-80))
	pass

func process_jump(delta):
	var impulse = (target - get_global_pos()).normalized() # direction of movement
	set_pos(get_pos()+impulse*delta*velocity)
	var diff = get_global_pos()-target
	#print(diff)
	if (abs(diff[0])+abs(diff[1])<1):
		target = Vector2(0,0)
		var space_state = get_world_2d().get_direct_space_state()
		var ray_cast_up_result = space_state.intersect_ray( get_global_pos(), get_global_pos()+Vector2(0,10) )
		if (not ray_cast_up_result.empty()):
			var diff = ray_cast_up_result.position-get_global_pos()
			if (abs(diff[0])+abs(diff[1])>0.5):
				target = ray_cast_up_result.position

func hog_is_close_enough(obj):
	target = obj.get_global_pos()
	pass