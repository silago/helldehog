extends Node2D


# load game data
# load scenes 
# load first 
var config_file = 'res://game.json'
var main_scene  = 'res://scenes/main.xml'
var MENU_GROUP  = 'menu_group'   
var IN_GAME 	= false
var TILEMAP_PREFIX = 'res://res/tilemaps/'

func load_first_scene():
	var json = File.new()
	json.open(config_file, 1)
	#print(json.get_as_text())
	var d = {}
	var err = d.parse_json(json.get_as_text())
	if (err!=OK):
		print("ERR")
		return false
	var start_scene_name = d["config"]["start_scene_name"]
	var start_scene_data = d["scenes"][start_scene_name]
	var tilemap_importer = get_node("/root/tilemap_importer")
	var first_scene = tilemap_importer.import_tilemap(TILEMAP_PREFIX,start_scene_name)
	
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
	
	return first_scene

func get_player():
	var player = ResourceLoader.load('res://res/player.ext')
	pass

func _on_start_pressed():
	var tilemap = load_first_scene()
	
	if (tilemap):
		add_child(tilemap)
		tilemap.set_pos(Vector2(0,0))
		var helldehog = preload("res://scenes/helldehog.scn").instance()
		var fish =  preload("res://scenes/fish.scn").instance()
		tilemap.add_child(helldehog)
		tilemap.add_child(fish)
		helldehog.set_pos(Vector2(100,500))
		fish.set_pos(Vector2(200,500))

	
	else:
		print("ERR TLMP IMPRT")
	pass
	#if (not IN_GAME):
	#	get_tree().get_nodes_in_group(MENU_GROUP).erase()
	##var scene = ResourceLoader.load(main_scene)
	##scene.set_name('current_scene')
	##add_child(scene.instance())
		
	#get_node("label").set_text("fooo")
	#get_node("/root/globals").some_function()
	
	
func _on_exit_pressed():
	pass
	get_node("/root").queue_free()
	
func _ready():
	#var game_inited = init_game()
	#if (game_inited == true):
	#	print("all good")

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