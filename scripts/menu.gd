extends Node2D


# load game data
# load scenes 
# load first 
var config_file = 'res://game.json'
var main_scene  = 'res://scenes/main.xml'
var MENU_GROUP  = 'menu_group'   
var IN_GAME 	= false
var TILEMAP_PREFIX = 'res://res/tilemaps/'
var next_scene = false
var exits = []
var player = false
var current_scene = false
func _process(delta):
	if not player:
		return false
	for e in exits:
		if abs(player.get_pos().x - e["position"][0])<20.0 and abs(player.get_pos().y - e["position"][1])<20.0:
			if (current_scene):
				current_scene.queue_free()
			load_tilemap(load_config(config_file),e["target"])
	print(player.get_pos())
	#delta - time from previous process call
	# if player is on exit then change scene

func load_config(config_file_name):
	var json = File.new()
	json.open(config_file_name, 1)
	#print(json.get_as_text())
	var d = {}
	var err = d.parse_json(json.get_as_text())
	if (err!=OK):
		print("ERR")
		return false
	return d

func load_tilemap(cfg,scene_name):
	#var start_scene_name = cfg["config"]["start_scene_name"]
	var start_scene_data = cfg["scenes"][scene_name]
	var tilemap_importer = get_node("/root/tilemap_importer")
	current_scene = tilemap_importer.import_tilemap(TILEMAP_PREFIX,scene_name)
	var object = load_objects(cfg,current_scene,scene_name)
	#var rain = Particles2D.new()
	#rain.set_amount(999)
	#rain.set_lifetime(10)
	#rain.set_emitting(true)
	#rain.set_emissor_offset(Vector2(800,0))
	#rain.set_emission_half_extents(Vector2(800,0))
	#rain.set_param(rain.PARAM_DIRECTION,10)
	#rain.set_param(rain.PARAM_LINEAR_VELOCITY,10)
	#rain.set_param(rain.PARAM_SPREAD,1)
	#rain.set_param(rain.PARAM_HUE_VARIATION,0.6)
	#rain.set_param(rain.PARAM_GRAVITY_STRENGTH,20)
	#if (rain):
	#	first_scene.add_child(rain)
	return current_scene

#func get_player():
#	var player = ResourceLoader.load('res://res/player.ext')
#	pass
#	var json = File.new()
#	json.open(config_file, 1)
#	#print(json.get_as_text())
#	var d = {}
#	var err = d.parse_json(json.get_as_text())
#	if (err!=OK):
#		print("ERR")
#		return false

func set_scene():
	pass

func load_objects(cfg,tilemap,scene_name):
	if (tilemap):
		add_child(tilemap)
		tilemap.set_pos(Vector2(0,0))
		player = preload("res://scenes/helldehog.scn").instance()
		tilemap.add_child(player)
		var start = cfg["scenes"][scene_name]["start"] 
		exits = cfg["scenes"][scene_name]["targets"]
		player.set_pos(Vector2(start[0],start[1]))
		
		var nps = preload("res://scenes/nps.scn").instance()
		tilemap.add_child(nps)
		nps.set_target(player)
		nps.set_pos(Vector2(start[0],start[1]))
		return true
	return false
	
func _on_start_pressed():
	var cfg  = load_config(config_file)
	var start_scene_name = cfg["config"]["start_scene_name"]	
	var tilemap = load_tilemap(cfg,start_scene_name)
		
	# var hiene =  preload("res://scenes/hiene.scn").instance()	
	# fish.set_scale(Vector2(0.1,0.1))
	# fish.get_node("anim").play("кгтrun")
	# fish.get_node("body").set_linear_velocity(Vector2(110,1500))
	# tilemap.add_child(hiene)


	#
	# hiene.set_pos(Vector2(200,500))
	# hiene.set_target(helldehog)
	# print("ERR TLMP IMPRT")
	pass
	# if (not IN_GAME):
	# get_tree().get_nodes_in_group(MENU_GROUP).erase()
	# #var scene = ResourceLoader.load(main_scene)
	# #scene.set_name('current_scene')
	# #add_child(scene.instance())
		
	# get_node("label").set_text("fooo")
	# get_node("/root/globals").some_function()	
	
func _on_exit_pressed():
	pass
	get_node("/root").queue_free()
	
func _ready():
	# var game_inited = init_game()
	# if (game_inited == true):
	# print("all good")

	var start = get_node('start')
	var exit = get_node('exit')
	var label = get_node('label')
	if (label):
		label.add_to_group(MENU_GROUP)
	if (exit):
		exit.add_to_group(MENU_GROUP)
		exit.connect('pressed',self,'_on_exit_pressed')
	
	if (start):
		start.add_to_group(MENU_GROUP)
		start.connect('pressed',self,'_on_start_pressed')
		
	set_process(true)