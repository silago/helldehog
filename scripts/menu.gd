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

func check_quests():

	for i in quests:
		var cando = true
		# add if active or maybe remove "active" in cfg
		if not(abs(player.get_pos().x - quests[i]["position"][0])<20.0 and abs(player.get_pos().y - quests[i]["position"][1])<20.0):
			cando = cando * false			
		for n in quests[i].needs:
			if quest_vars[n] != quests[i].needs[n]:
				cando = cando * false
			pass
		if cando:
			for s in quests[i].sets:
				quest_vars[s] = quests[i].sets[s]
			pass
	pass

func init_quests(cfg):
	var q = {}
	quests = q

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
					rat.set_pos(Vector2(100,500))
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
	
func _on_exit_pressed():
	pass
	get_node("/root").queue_free()

	

func load_script_scenes():
	var json = File.new()
	json.open("res://scenes.json", 1)
	var d = {}
	var err = d.parse_json(json.get_as_text())
	if (err!=OK):
		return false
	pass
	script_scenes = d
	
func process_script_scenes():
	if (not script_scenes):
		return false
	for i in script_scenes:
		var sc = script_scenes[i]
		var condition_result = true	
		for cond in sc["conditions"]:
			if cond == "varsSet":
				for c in sc["conditions"][cond]:
					if script_scenes_vars[c]!=sc["conditions"][cond][c]:
						condition_result = false
			elif cond == "distnanceLT" or cond == "distanceGT":
				for c in sc["conditions"][cond]:
					var n1_name = sc["conditions"][cond][0]
					var n2_name = sc["conditions"][cond][1]
					var dis = sc["conditions"][cond][3]
					var n1 = get_node("tilemap/"+n1_name)
					var n2 = get_node("tilemap/"+n2_name)
					var n1_pos = n1.get_position_in_parent()
					var n2_pos = n2.get_position_in_parent()
					var dif = n1_pos-n2_pos
					if cond == "distanseLT":
						if  dif.x>dis or dif.y>dis:
							condition_result = false
					if cond == "distanseGT":
						if  dif.x<dis or dif.y<dis:
							condition_result = false
		if (condition_result==true):
			for n in sc["actions"]:
				var action_node = get_node(n)
				for a in sc["actions"][n]:
					if a == "say":
						n.say(sc["actions"][n][a])
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
	for e in exits:
		if abs(player.get_pos().x - e["position"][0])<20.0 and abs(player.get_pos().y - e["position"][1])<20.0:
			if (current_scene):
				current_scene.queue_free()
			load_tilemap(load_config(config_file),e["target"])
	#print(player.get_pos())
	process_script_scenes()