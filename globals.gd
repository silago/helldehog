extends Node

var quests = []
var quest_objects = {}
var quest_vars = {'butterfliesLeftToCatch':1}
var quest_requirements = {
	'quest_1':['helldehog','ыгзукрщпsuperhog','noway','gui',
		'butterfly1'
	]
}

func add_to_quest_objects(name,obj):
	print(name)
	quest_objects[str(name)]=obj
	for q in quest_requirements:
		if name in quest_requirements[q]:
			quest_requirements[q].remove(quest_requirements[q].find(name))
		else:
			print(name+" not found")
		if quest_requirements[q].size() == 0:
			call(q+'_prepare')
			quest_requirements.erase(q)
	print(quest_requirements)
		
func quest_1(ev,v = false):
	#print(ev)
	#print(v)
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
		quest_objects['noway'].queue_free()
	if (ev == 'butterflyCollided' and quest_vars['quest_1_got']):
		quest_vars['butterfliesLeftToCatch']-=1
		if quest_vars['butterfliesLeftToCatch']==0:
			quest_objects[v].catched()
			quest_objects['gui'].say('I\'m a good hog. I\'ve catched all I need. ..... AAAAAAAAAAA!!!!!!!')
			quest_objects['helldehog'].apply_impulse(Vector2(100,-20),Vector2(250,-50))
			quest_objects['ыгзукрщпsuperhog'].queue_free()

func quest_1_prepare():
	quest_vars['quest_1_got']=false
	quest_objects['ыгзукрщпsuperhog'].connect('superhogCollided',self,'quest_1',['superhogCollided'])
	quest_objects['noway'].connect('nowayCollided',self,'quest_1',['nowayCollided'])
	quest_objects['butterfly1'].connect('ыгзукрщпbutterflyCollided',self,'quest_1',['butterflyCollided','butterfly1'])
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
	
func process_script_scenes(script_scenes,script_scenes_vars):
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
					print(n1_name)
					var n1_pos = n1.get_pos()
					print(n2_name)
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
	
func load_tiled_map():
	pass