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
		'helldehog':['PlayerReady'],
		'ыгзукрщпsuperhog' :['PlayerSuperhogCollided'],
		'restrictor':['PlayerRestrictorCollided'],
		'gui':[],
		'butterfly1':['PlayerButterflyCollided'],
		'motherhog':['PlayerMotherhogCollided'],
		'smallhog2':['PlayerSmallHogCollided'],
		'smallhog3':['PlayerSmallHogCollided'],
		'branch':['PlayerBranchCollidedSpacePressed'],
		'branch_place':['PlayerSmallHogCollidedSpacePressed'],
		'oldhog':['PlayerOldhogCollided'],
		'stick':['PlayerStickCollidedSpacePressed'],
		'pit':['зешPlayerPitEnter'],
	}
}


const SIGNAL_CALLER = 0

var    quest_data =  {
	    'PlayerRestrictorCollided': {
            'TALK_TO_SUPERHOG':[
            ]
        },
		'PlayerReady':{
			'TALK_TO_SUPERHOG':[
				['SAY',[tr('INTRO_1'),tr('INTRO_2'),tr('INTRO_3'),tr('INTRO_4')]],
			]
		},
		'PlayerMotherhogCollided': {
			'CATCH_HOGS':[
				['SET_STATE',['FIND_SMALL']],
				['SAY',[tr('MOTHERHOG_1'),tr('MOTHERHOG_2')]]
			],
			'SMALLHOG_SAVED':[
				['SAY',[tr('MOTHERHOG_4')]],
				['SET_STATE',['ALL_SAVED']],
				['SET_NPC_STATE',['smallhog2',0]],
				['SET_NPC_STATE',['smallhog3',0]],
				['SET_NPC_STATE',['smallhog4',0]],
			],
			'FIND_BRANCH':[
				['SAY_ONCE',[tr('MOTHERHOG_3')]]
			]
		},
		'PlayerSmallHogCollided': {
			'FIND_SMALL':[
				['SAY',[tr('SMALLHOG_1'),tr('SMALLHOG_2'),tr('SMALLHOG_3')]],
				['SET_STATE',['FIND_BRANCH']]
			],
			'BRANSH_PUSHED':[
				['SAY',[tr('SMALLHOG_4'),tr('SMALLHOG_5')]],
				['SET_STATE',['SMALLHOG_SAVED']]
			],
			'SMALLHOG_SAVED':[
			]
		},
		'зешPlayerPitEnter':{
			'TALK_TO_SUPERHOG':[
				['GAMEOVER',['']],
				['SAY',[tr('GAMEOVER_1')]],		
			],
			'CATCH_HOGS':[
				['GAMEOVER',['']],
				['SAY',[tr('GAMEOVER_1')]],		
			],
			'FIND_BRANCH':[
				['GAMEOVER',['']],
				['SAY',[tr('GAMEOVER_1')]],		
			],
			'FINDSMALL':[
				['GAMEOVER',['']],
				['SAY',[tr('GAMEOVER_1')]],		
			]
		},
		'PlayerBranchCollidedSpacePressed': {
			'FIND_BRANCH':[
				['HIDE',['branch']],
				['SET_STATE',['GOT_BRANCH']]
			]
		},
		'PlayerSmallHogCollidedSpacePressed': {
			'GOT_BRANCH':[
				['GET_POS',['smallhog4']],
				['SET_POS',['branch']],
				['SET_ROT',['branch',-0.4]],
				['SHOW',['branch']],
				['SET_STATE',['BRANSH_PUSHED']],
				['SET_NPC_STATE',['smallhog2',1]],
				['SET_NPC_STATE',['smallhog3',1]],
				['SET_NPC_STATE',['smallhog4',1]],
			]
		},
		'PlayerOldhogCollided':{
			'SMALLHOG_SAVED':[
			   ['SAY',[
					tr('OLDHOG_1')
					]],
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
			'ALL_SAVED':[
			  ['SAY',[
					tr('OLDHOG_6'),
					tr('OLDHOG_7'),
					tr('OLDHOG_8'),
					]
				]
			],
            'TALK_TO_SUPERHOG':[
                ['SAY',[
					tr('OLDHOG_1'),
					tr('OLDHOG_2'),
					tr('OLDHOG_3'),
					tr('OLDHOG_4')
					]
				],
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
					quest_objects['gui'].say(action_data)
					#quest_objects['gui'].set_quest(action_data)
				if (action == 'KICK'):
					pass	
				if (action == 'REMOVE'):
					if (action_data.size()==0):
						caller.queue_free()	
					else:
						quest_objects[action_data[0]].queue_free()
				if (action == 'GAMEOVER'):
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
				print('connect')
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

func get_player():
	return quest_objects['helldehog']