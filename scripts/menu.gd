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
var rock = false
var current_scene = false
var alert = false
var alert_queue = []
var script_scenes = false
var script_scenes_vars = {}
var quests = {}
var quest_vars = []
var once = false





#func show_message(msg):	
#	if not alert:
#		alert = Label.new()
#		alert.set_text(msg)
#		alert.set_pos(Vector2(300,500))
#		add_child(alert)
#	return




#func load_config(config_file_name):
#		
#	var json = File.new()
#	json.open(config_file_name, 1)
#	#print(json.get_as_text())
#	var d = {}
#	var err = d.parse_json(json.get_as_text())
#	if (err!=OK):
#		print("ERR")
#		return false
#	return d

func create_from_object_layer(path,tilemap):
	var d = get_node("/root/globals").get_json_file(path)

	for i in d["layers"]:
		if (i["type"]=="objectgroup"):
			for o in i["objects"]:
				if ("type" in o["properties"] and o["properties"]["type"]=="rat"):
					var scn_path = "res://scenes/"+o["properties"]["type"]+"scn"
					var rat = preload("res://scenes/rat.scn").instance()
					if ("name" in o["properties"]):
						rat.set_name(o["properties"]["name"])
						tilemap.add_child(rat)
						rat.set_pos(Vector2(o.x,o.y))
						rat.set_target(rat)

func load_tilemap(cfg,scene_name):
	var start_scene_data = cfg["scenes"][scene_name]
	var tilemap_importer = get_node("/root/tilemap_importer")
	var layers = tilemap_importer.import_tilemap(TILEMAP_PREFIX,scene_name)
	return position_layers(layers)



func position_layers(layers):
	var tilemap_importer = get_node("/root/tilemap_importer")
	var ls  = tilemap_importer.position_layers(layers)
	var bg = ls[0]
	var g  = ls[1]
	var fg = ls[2]
	
	add_child(bg)
	add_child(g)
	add_child(fg)
	return true
	
func load_objects(cfg,tilemap,scene_name):
	if (tilemap):
		add_child(tilemap)
		tilemap.set_pos(Vector2(0,0))
		player = preload("res://scenes/helldehog.scn").instance()
		tilemap.add_child(player)
		var start = cfg["scenes"][scene_name]["start"] 
		player.set_pos(Vector2(start[0],start[1]))
		player.set_name("player")
		var nps = preload("res://scenes/rat.scn").instance()
		tilemap.add_child(nps)
		nps.set_target(player)
		nps.set_pos(Vector2(start[0],start[1]))
		return true
	return false
	
func _on_start_pressed():
	var cfg = get_node("/root/globals").get_json_file(config_file)
	player = preload("res://scenes/helldehog.scn").instance()
	player.set_pos(Vector2(100,20))
	player.set_name("player")
	
	rock   = preload("res://scenes/rock.scn").instance()
	rock.set_pos(Vector2(102,22))
	rock.set_name("rock")
	#var cfg  = load_config(config_file)
	var start_scene_name = cfg["config"]["start_scene_name"]	
	load_tilemap(cfg,start_scene_name)
	#tilemap.set_name("tilemap")
	#var layers = get_node("tilemap").get_children()
	#for layer in layers:
	#	#get_node("tilemap").get_p
	#	pass
	
	get_node("start").hide()
	get_node("exit").hide()	

func load_script_scenes():
	var json = File.new()
	json.open("res://scenes.json", 1)
	var d = {}
	var err = d.parse_json(json.get_as_text())
	if (err!=OK):
		print("err config loading")
		return false
	pass
	script_scenes = d
	
func process_script_scenes():
	return
	if (script_scenes==false):
		print ("no script scenes")
		return false
	return get_node("/root/globals").process_script_scenes(script_scenes,script_scenes_vars)
	
func level1():
	var b = get_node("Level1")
	b.load_scene()
																					
func _ready():
	get_node('exit').connect('pressed',self,'_on_exit_pressed')
	get_node('start').connect('pressed',self,'_on_start_pressed')	
	get_node('Level1').connect('pressed',self,'level1')	
	load_script_scenes()
	set_process(true)
	
	

func _process(delta):
	if not player:
		#print("not player")
		return false
	process_script_scenes()