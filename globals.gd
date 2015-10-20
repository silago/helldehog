extends Node


func some_function():
	print("some function called")

func _ready():
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