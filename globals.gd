extends Node

var quests = []
var quest_objects = {}
var quest_vars = {
	'BUTTERLYCATCHED':0,
	'BUTTERLYTOCATCH':1
}

var methods = {}
var stack = []
var current_scene = 'water_scene.json'
var saved_position = [950,470]
var key_chaims_sound


var main 


var quest_requirements = {
	'quest_1':	{
		'helldehog':[],
		'ыгзукрщпsuperhog' :['PlayerSuperhogCollided'],
		'restrictor':['PlayerRestrictorCollided'],
		'gui':[],
		'butterfly1':['PlayerButterflyCollided'],
		'motherhog':['PlayerMotherhogCollided'],
		'smallhog1':['PlayerSmallHogCollidedSpacePressed'],
		'smallhog2':['PlayerSmallHogCollided'],
		'branch':['PlayerBranchCollidedSpacePressed'],
		'oldhog':['PlayerOldhogCollided'],
		'stick':['PlayerStickCollidedSpacePressed'],
	}
}


const SIGNAL_CALLER = 0

var    quest_data =  {
	    'PlayerRestrictorCollided': {
            'TALK_TO_SUPERHOG':[
                ['SAY',['hello']],
            ]
        },
		'PlayerMotherhogCollided': {
			'CATCH_HOGS':[
				['SAY',['find my hogs']]
			]
		},
		'PlayerSmallhogCollided': {
			'CATCH_HOGS':[
				['SAY',['GetStick']]
			]
		},
		'PlayerSmallHogCollided': {
			'CATCH_HOGS':[
				['SAY',['fefe']],
				['SET_STATE',['FIND_BRANCH']]
			]
		},
		'PlayerBranchCollidedSpacePressed': {
			'FIND_BRANCH':[
				['SAY',['GOT']],
				['HIDE',['branch']],
				['SET_STATE',['GOT_BRANCH']]
			]
		},
		'PlayerSmallHogCollidedSpacePressed': {
			'GOT_BRANCH':[
				['GET_POS',['smallhog1']],
				['SET_POS',['branch']],
				['SET_ROT',['branch',40]],
				['SHOW',['branch']],
				['FADE',[]],
				['SET_STATE',['SMALLHOG_SAVED']],
				#['GET_VAR',['helldehog','pos']],
				#['SET_VAR',['branch','pos']],
				#['GET_VAR',['smallhog1','pos']],
				#['GET_COS',[]],
				#['CUSTOM_ACTION',[]]
			]
		},
		'PlayerOldhogCollided':{
			'SMALLHOG_SAVED':[
			   ['SAY',['catch']],
               ['SET_STATE',['FIND_STICK']]
			],
			'FOUND_STICK':[
			   ['SAY',['good']],
			]
		},
		'PlayerStickCollidedSpacePressed':{
			'FIND_STICK':[
			   ['SET_STATE',['FOUND_STICK']],
			   ['HIDE',['stick']],
			]
		},
        'PlayerSuperhogCollided': {
            'TALK_TO_SUPERHOG':[
                ['SAY',['catch']],
                ['REMOVE',['restrictor']],
                ['SET_STATE',['CATCH_HOGS']]
            ]
        },
        'PlayerButterflyCollided':{
            'CATCH_BUTTERFLIES':[
                ['INC_VAR',['BUTTERLYCATCHED']],
                ['REMOVE',[]],
				['EMIT_SIGNAL_IF_EQUAL',['BUTTERLYCATCHED',1,'AllbutterfliesCatched']]
            ]
        },
		'AllbutterfliesCatched':{
			'CATCH_BUTTERFLIES':[
			    ['SET_STATE',['ALLCATCHED']],
				['PUSH_QUERY',['helldehog','RUN_JUMP_RIGHT']]
			]
		},
		'PlayerFallerCollided':{
			'ALLCATCHED':[
				['SET_STATE',['FALLED']],
				['CLEAR_QUERY',['helldehog','RUN_JUMP_RIGHT']]
			]
		}
    }
var STATE = 'TALK_TO_SUPERHOG';
func signal_resolver(sig_name,caller = null):
		print(STATE)
		print(sig_name)
		#print('resolver')
		if (quest_data.has(sig_name) and quest_data[sig_name].has(STATE)):
			for a in quest_data[sig_name][STATE]:
				var action 		= a[0]
				var action_data = a[1]
				if (action == 'SAY'):
					quest_objects['gui'].say(action_data[0])
					quest_objects['gui'].set_quest(action_data[0])
				if (action == 'KICK'):
					pass	
				if (action == 'REMOVE'):
					if (action_data.size()==0):
						caller.queue_free()	
					else:
						quest_objects[action_data[0]].queue_free()
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
				if (action == 'SET_POS'):
					quest_objects[action_data[0]].set_pos(stack[0])
					#stack.erase(0)
				if (action == 'GET_POS'):
					stack.append(quest_objects[action_data[0]].get_pos())
				if (action == 'SET_ROT'):
					quest_objects[action_data[0]].set_rot(int(action_data[1]))
				if (action == 'SAVE'):
					save_game()
func old_save_game():
	pass
	# objects to save:
	#	1) game_state
	#	2) current_map
	#	3) checkpoint_id
	#var save = current_mape & game_state_id & checkpoint_id 

func add_to_quest_objects(name,obj):
	#print(name)
	quest_objects[str(name)]=obj
	for q in quest_requirements:
		if name in quest_requirements[q]:
			for s in quest_requirements[q][name]:
				print(s)
				obj.connect(s,self,'signal_resolver')
			quest_requirements[q].erase(name)
		else:
			print(name+" not found")
		if quest_requirements[q].size() == 0:
			call(q+'_prepare')
			quest_requirements.erase(q)
	#print(quest_requirements)
		
func quest_1(ev,v = false):
	return
	if (ev == 'nowayCollided' and not quest_vars['quest_1_got']):
		quest_objects['gui'].say('I must talk to Hogge first.')
		var player = quest_objects['helldehog']
		var lv = player.get_linear_velocity()
		lv.x = lv.x*-1
		lv.y = lv.y*-1
		player.set_linear_velocity(lv)
	if (ev == 'superhogCollided'):
		quest_objects['gui'].say('Hello. Here is a wolf in the forest. Go and catch some butterflies and we shall go away from here.')
		quest_vars['quest_1_got']=true
		if (quest_objects.has('noway')):
			quest_objects['noway'].queue_free()
			quest_objects.erase('noway')
	if (ev == 'butterflyCollided' and quest_vars['quest_1_got']):
		quest_vars['butterfliesLeftToCatch']-=1
		if quest_vars['butterfliesLeftToCatch']==0:
			quest_objects[v].catched()
			quest_objects['gui'].say('I\'m a good hog. I\'ve catched all I need. ..... AAAAAAAAAAA!!!!!!!')
			quest_objects['helldehog'].apply_impulse(Vector2(100,-20),Vector2(250,-50))
			quest_objects['ыгзукрщпsuperhog'].queue_free()

func quest_1_prepare():
	#quest_vars['quest_1_got']=false
	#quest_objects['ыгзукрщпsuperhog'].connect('superhogCollided',self,'quest_1',['superhogCollided'])
	#quest_objects['noway'].connect('nowayCollided',self,'quest_1',['nowayCollided'])
	#quest_objects['butterfly1'].connect('ыгзукрщпbutterflyCollided',self,'quest_1',['butterflyCollided','butterfly1'])
	pass
	


#func prepare_quests():
#	quest_1_prepare()
#	pass	


#func send_signal(sig):
#	for listener in listeners:
#		if (listener.has_method('get_event')):
#			pass

func some_function():
	print("some function called")

func _ready():
	#prepare_quests()
	print("globals ready")
	main = Node2D.new()
	#key_chaims_sound = StreamPlayer.new()
	#key_chaims_sound.set_stream(load("res/music/KeyChimes.ogg"))
	#key_chaims_sound.play()
	
	#KeyChimes.ogg
	
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
		#"state":STATE,
		"state":STATE,
		"stack":stack
		}
	#var savenodes = get_tree().get_nodes_in_group("Persist")
	#for i in savenodes:
	#	var nodedata = i.save()
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
