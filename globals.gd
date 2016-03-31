extends Node

var camera
var quests = []
var quest_vars = {
	'BUTTERLYCATCHED':0,
	'BUTTERLYTOCATCH':1
}

var methods = {}
var stack = []
var current_scene = 'water_scene.json'
var saved_position = [950,470]
var key_chaims_sound
var waiting_to_change = false
var main 
var next_scene



const SIGNAL_CALLER = 0
var    quest_objects={}
var    quest_data =  {}

var STATE = 'TALK_TO_SUPERHOG'
#var STATE = 'QUEST_DONE'
func set_camera(c):
	self.camera = c
func get_camera():
	return self.camera

func signal_resolver(sig_name,caller = null):
		print('got signal')
		print(STATE)
		print(sig_name)
		#print('resolver')
		if (quest_data.has(sig_name) and quest_data[sig_name].has(STATE)):
			for a in quest_data[sig_name][STATE]:
				var action 		= a[0]
				var action_data = a[1]
				if (action == 'SAY_ONCE'):
					quest_objects['gui'].say(action_data)
					quest_data[sig_name][STATE].remove(quest_data[sig_name][STATE].find(a))
				if (action == 'SAY'):
					if (quest_objects.has('gui')):
						quest_objects['gui'].say(action_data)
					#quest_objects['gui'].set_quest(action_data)
				if (action == 'KICK'):
					pass	
				if (action == 'REMOVE'):
					if (action_data.size()==0):
						caller.queue_free()	
					else:
						quest_objects[action_data[0]].queue_free()
				if (action == 'GAMEOVER_WIN'):
					waiting_to_change = true 
					next_scene = "res://scenes/main_menu.scn"
					set_process(true)
				if (action == 'GAMEOVER_FAIL'):
					quest_objects['helldehog'].move_to_start()
				if (action == 'SET_STATE'):
					STATE = action_data[0]
					quest_objects['gui'].set_quest(STATE)
					quest_objects['helldehog'].get_node("chains").play()
				if (action == 'INC_VAR'):
					quest_vars[action_data[0]]+=1
				if (action == 'EMIT_SIGNAL_IF_EQUAL'):
					if (quest_vars[action_data[0]]==action_data[1]):
						signal_resolver(action_data[2])
				if (action == 'PUSH_QUERY'):
					quest_objects[action_data[0]].append_query(action_data[1])
				if (action == 'CLEAR_QUERY'):
					quest_objects[action_data[0]].clear_query()
				if (action == 'SHOW'):
					quest_objects[action_data[0]].show()
				if (action == 'HIDE'):
					quest_objects[action_data[0]].hide()
				if (action == 'ACTION'):
					quest_objects[action_data[0]].action()
				if (action == 'SET_POS'):
					quest_objects[action_data[0]].set_pos(stack[0])
					#stack.erase(0)
				if (action == 'GET_POS'):
					stack.append(quest_objects[action_data[0]].get_pos())
				if (action == 'SET_ROT'):
					quest_objects[action_data[0]].set_rot((action_data[1]))
				if (action == 'SAVE'):
					save_game()
				if (action == 'SET_NPC_STATE'):
					quest_objects[action_data[0]].set_state(int(action_data[1]))
				if (action == 'CHANGE_SCENE'):
					change_scene('res://'+action_data[0])
func old_save_game():
	pass
	# objects to save:
	#	1) game_state
	#	2) current_map
	#	3) checkpoint_id
	#var save = current_mape & game_state_id & checkpoint_id 

func add_to_quest_objects(name,obj,signals=[]):
	#print(name)
	#if (signals.size()==0):
	#	print("!!!!!")
	#	print(name)
	quest_objects[str(name)]=obj
	for s in signals:
		obj.connect(s,self,'signal_resolver')
	return
	


func _ready():
	set_pause_mode(3)
	set_process_input(true)
	for i in get_tree().get_root().get_children():
		print(i.get_name())
	main = Node2D.new()
	
func get_json_file(path):
	var json = File.new()
	json.open(path, 1)
	var d = {}
	var err = d.parse_json(json.get_as_text())
	if (err!=OK):
		print("err config loading")
		return false
	pass
	return d

	
	
func save_game():
	var savegame = File.new()
	savegame.open("user://savegame.save", File.WRITE)
	print(quest_objects['helldehog'].get_pos())
	var pos = quest_objects['helldehog'].get_pos()
	
	var savedata = {
		"scene":"res://scenes/water_scene.scn",
		"x": pos.x,
		"y": pos.y,
		"state":STATE,
		"stack":stack
		}
	savegame.store_line(savedata.to_json())
	savegame.close()
	if !savegame.file_exists("user://savegame.save"):
		print('failed to save file')
		
func load_game():
	var savegame = File.new()
	if !savegame.file_exists("user://savegame.save"):
		print('no savefile found')
		return
	var currentline = {}
	var savedata = get_json_file("user://savegame.save")

	main.set_name('_')
	main.queue_free()
	main = load(savedata.scene).instance()
	get_tree().get_root().add_child(main)

	STATE=savedata.state
	stack=savedata.stack
	quest_objects['helldehog'].set_name('_helldehog')
	quest_objects['helldehog'].queue_free()
	var hoge = load("res://scenes/helldehog.scn")
	var player = hoge.instance()
	var x = savedata.x
	var y = savedata.y
	player.set_pos(Vector2(x,y))
	main.add_child(player)
	
	quest_objects['helldehog']=player
	quest_objects['gui'].set_quest(STATE)
	player.set_name('Helldehog')
	print('loaded')
	pass	

func _process(delta):
	if (waiting_to_change):
		if (!get_tree().is_paused()):
			waiting_to_change = false
			set_process(false)
			change_scene(next_scene)
			
func load_quest_data(path):
	self.quest_data = get_json_file(path)
	#print(quest_data)
	
func change_scene(path):
	get_tree().set_pause(true)
	get_tree().get_root().get_node(".").get_node("container").set_name(".container")
	get_tree().get_root().get_node(".").get_node(".container").queue_free()
	#container.queue_free()
	
	var scene = load(path).instance()
	scene.set_name("container")
	get_tree().get_root().get_node(".").add_child(scene)
	print(">>>")
	for i in get_tree().get_root().get_children():
		print(i.get_name())
	print("<<<")
	get_tree().set_pause(false)

func toggle_menu():
	var m = get_tree().get_root().get_node(".").get_node("main_menu")
	var c = get_tree().get_root().get_node(".").get_node("container")
	if (m.is_hidden()):
		print("m was hidden")
		get_tree().set_pause(true)
		get_camera().set_zoom(Vector2(1,1))
		m.show()
		c.hide()
	else:
		get_tree().set_pause(false)
		m.hide()
		c.show()
	pass

func set_state(statename):
	STATE=statename
	
func _input(event):
	if(event.is_action_released("escape")):
		toggle_menu()
			
func get_player():
	return quest_objects['helldehog']