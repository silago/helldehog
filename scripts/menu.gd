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
var alert = false
var alert_queue = []
var script_scenes = false
var script_scenes_vars = {}
var quests = {}
var quest_vars = []
var once = false


func show_message(msg):
	if not alert:
		alert = Label.new()
		alert.set_text(msg)
		alert.set_pos(Vector2(300,500))
		add_child(alert)
	return




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

func create_from_object_layer(path,tilemap):
	var json = File.new()
	json.open(path, 1)
	#print(json.get_as_text())
	var d = {}
	var err = d.parse_json(json.get_as_text())
	if (err!=OK):
		print("ERR")
		return false
	
	for i in d["layers"]:
		if (i["type"]=="objectgroup"):
			for o in i["objects"]:
				if (o["properties"]["type"]=="rat"):
					var rat = preload("res://scenes/rat.scn").instance()
					if (o["properties"]["name"]):
						rat.set_name(o["properties"]["name"])
					tilemap.add_child(rat)
					rat.set_pos(Vector2(o.x,o.y))
					rat.set_target(rat)

func load_tilemap(cfg,scene_name):
	#var start_scene_name = cfg["config"]["start_scene_name"]
	var start_scene_data = cfg["scenes"][scene_name]
	var tilemap_importer = get_node("/root/tilemap_importer")
	current_scene = tilemap_importer.import_tilemap(TILEMAP_PREFIX,scene_name)
	var object = load_objects(cfg,current_scene,scene_name)
	create_from_object_layer(TILEMAP_PREFIX+scene_name,current_scene)
	return current_scene

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
		player.set_name("player")
		var nps = preload("res://scenes/rat.scn").instance()
		tilemap.add_child(nps)
		nps.set_target(player)
		nps.set_pos(Vector2(start[0],start[1]))
		return true
	return false
	
func _on_start_pressed():
	var cfg  = load_config(config_file)
	var start_scene_name = cfg["config"]["start_scene_name"]	
	var tilemap = load_tilemap(cfg,start_scene_name)
	tilemap.set_name("tilemap")
#<<<<<<< HEAD
#	get_node("StreamPlayer").play()
	get_node("start").hide()
	get_node("exit").hide()
#=======
#	var l1 = get_node("tilemap/l2")
#	var old_film_scene = preload("res://res/materials/material.scn").instance()#
#	l1.add_child(old_film_scene)	
#	l1.move_child(old_film_scene,1)
	#old_film.set_as_top_level(true)
	#l1.hide()
	#get_node("oldfilm").set_owner(get_node("tilemap/l1"))
#>#>>>>>> 5ff9f03bd3a5c01c2103ee831e71346a97dc0bf7
	
func _on_exit_pressed():
	pass
	get_node("/root").queue_free()

	

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
	if (script_scenes==false):
		print ("no script scenes")
		return false
	if (once==true):
		return false	
	for i in script_scenes:
		var sc = script_scenes[i]
		var condition_result = true	
		for cond in sc["conditions"]:
			if condition_result == false:
				break
			if cond == "varsSet":
				for c in sc["conditions"][cond]:
					#print(script_scenes_vars)
					if (sc["conditions"][cond][c]==false):
						if (script_scenes_vars.has(c)) and script_scenes_vars[c]!=sc["conditions"][cond][c]:
							condition_result = false
					else:
						if (!script_scenes_vars.has(c)) or script_scenes_vars[c]!=sc["conditions"][cond][c]:
							condition_result = false
			elif cond == "distanceLT" or cond == "distanceGT":
				for c in sc["conditions"][cond]:
					var n1_name = c[0]
					var n2_name = c[1]
					var dis = c[2]
					#print("tilemap/"+n1_name)
					var n1 = get_node("tilemap/"+n1_name)
					var n2 = get_node("tilemap/"+n2_name)
					var n1_pos = n1.get_pos()
					var n2_pos = n2.get_pos()
					var dif = n1_pos-n2_pos
					#print(dif.x)
					#print(dis)
					if cond == "distanceLT":
						#print(str(dif.x)+" "+str(dif.y))
						if  abs(dif.x)>dis or abs(dif.y)>dis:
							condition_result = false
							#print("condition lower failed for "+i)
					if cond == "distanceGT":
						if  abs(dif.x)<dis and abs(dif.y)<dis:
							condition_result = false
							#print("condition greater failed for "+i)
		if (condition_result==true):
			for n in sc["actions"]:
				var action_node = get_node(n)
				for a in sc["actions"][n]:
					if a == "say":
						get_node("tilemap/"+n).say(sc["actions"][n][a])
					if a == "set_target":
						get_node("tilemap/"+n).set_target(get_node("tilemap/"+sc["actions"][n][a]))
			for n in sc["set"]:
				script_scenes_vars[n] = sc["set"][n]

																					
func _ready():
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
	
	load_script_scenes()
	set_process(true)
	
	

func _process(delta):
	if not player:
		return false
	#for e in exits:
	#	if abs(player.get_pos().x - e["position"][0])<20.0 and abs(player.get_pos().y - e["position"][1])<20.0:
	#		if (current_scene):
	#			current_scene.queue_free()
	#		load_tilemap(load_config(config_file),e["target"])
	#print(player.get_pos())
	process_script_scenes()