extends Node

var map_path = ""
var error_popup

const FLIPPED_HORIZONTALLY_FLAG = 0x80000000
const FLIPPED_VERTICALLY_FLAG   = 0x40000000
const FLIPPED_DIAGONALLY_FLAG   = 0x20000000

#func _ready():
#	error_popup = get_node("ErrorPopup")

func createTileset(var data, var cell_size,var path_prefix):
	var map_path = path_prefix
	
	var ts = TileSet.new()
	var size = cell_size
	for t in data:
		var path = map_path.get_base_dir() + "/" + t["image"]
		#var file_name = t["image"]
		#var path = map_path.get_base_dir() + "/" + file_name
		var file = File.new()
		if (!file.file_exists(path)):
			print("couldn't find the tileset: " + path)
			#error_popup.set_text("couldn't find the tileset: " + path)
			#error_popup.popup()
			return false
		var texture = load(path)
		texture.set_flags(0)
		var width = texture.get_width()
		width -= width % int(cell_size.x)
		var height = texture.get_height()
		height -= height % int(cell_size.y)
		var count = t["firstgid"]
		var tiles
		if t.has("tiles"):
			tiles = t["tiles"]
		for y in range(0, height, cell_size.y):
			for x in range(0, width, cell_size.x):
				var xy = Vector2(x, y)
				var rect = Rect2(xy, size)
				ts.create_tile(count)
				ts.tile_set_texture(count, texture)
				ts.tile_set_region(count, rect)
				var id = str(count-1)

				if t.has("tiles"):
					for tile in tiles:
						if tile == id and tiles[tile].has("objectgroup"):
							for obj in tiles[tile]["objectgroup"]["objects"]:
								if !obj.has("polyline") and !obj.has("polygon") and !obj.has("ellipse"):
									var w = obj["width"]
									var h = obj["height"]
									var xx = obj["x"]
									var yy = obj["y"]
									var rectshape = RectangleShape2D.new()
									rectshape.set_extents(Vector2(w/2, h/2))
									ts.tile_set_shape(count, rectshape)
									ts.tile_set_shape_offset(count, Vector2(w/2 + xx, h/2 + yy))
								elif obj.has("ellipse"):
									var w = obj["width"]
									var h = obj["height"]
									var xx = obj["x"]
									var yy = obj["y"]
									if w == h:
										var circleshape = CircleShape2D.new()
										circleshape.set_radius(w/2)
										ts.tile_set_shape(count, circleshape)
										ts.tile_set_shape_offset(count, Vector2(w/2 + xx, h/2 + yy))
									else:
										var capsuleshape = CapsuleShape2D.new()
										capsuleshape.set_radius(w/2)
										capsuleshape.set_height(h/2)
										ts.tile_set_shape(count, capsuleshape)
										ts.tile_set_shape_offset(count, Vector2(w/2 + xx, h/2 + yy))
								elif obj.has("polygon"):
									var polygonshape = ConvexPolygonShape2D.new()
									var vectorarray = Vector2Array()

									var xx = obj["x"]
									var yy = obj["y"]

									for point in obj["polygon"]:
										vectorarray.push_back(Vector2(point["x"] + xx, point["y"] + yy))

									polygonshape.set_points(vectorarray)
									ts.tile_set_shape(count, polygonshape)
									ts.tile_set_shape_offset(count, Vector2(0, 0))
								elif obj.has("polyline"):
									var polygonshape = ConcavePolygonShape2D.new()
									var vectorarray = Vector2Array()

									var xx = obj["x"]
									var yy = obj["y"]

									for point in obj["polyline"]:
										vectorarray.push_back(Vector2(point["x"] + xx, point["y"] + yy))

									polygonshape.set_segments(vectorarray)
									ts.tile_set_shape(count, polygonshape)
									ts.tile_set_shape_offset(count, Vector2(0, 0))

				count += 1
	return ts

func import_tilemap(path,name):
	var map_path = path+name
	#var root_node = get_tree().get_edited_scene_root()
	#if root_node == null:
	#	print("No root node found. Please add one before trying to import a tiled map")
	#	error_popup.set_text("No root node found. Please add one before trying to import a tiled map")
	#	error_popup.popup()
	#	return
	var json = File.new()
	if (json.file_exists(map_path)):
		json.open(map_path, 1)
	else:
		print("could't open json file: "+map_path)
		return false
	#	print("The map file " + map_path +" seems to not exist.")
	#	error_popup.set_text("The map file " + map_path +" seems to not exist.")
	#	error_popup.popup()
	#	return false
	var map_data = {}
	var err = map_data.parse_json(json.get_as_text())
	if (err!=OK):
		print("Error parsing the map file. Please make sure it's in a valid format. Currently only .json is supported")
		return false

	var tilemap_root = Node2D.new()
	tilemap_root.set_name("TileScene")

	var tileset_data = map_data["tilesets"]
	var cell_size = Vector2(map_data["tilewidth"], map_data["tileheight"])
	var tileset = createTileset(tileset_data, cell_size,path,true)
	var uncollidable_tileset = createTileset(tileset_data, cell_size,path,false)
	
	if(!tileset):
		print("Something went wrong while creating the tileset. Make sure all files are at the right path")
		return false

	#root_node.add_child(tilemap_root)
	#tilemap_root.set_owner(root_node)

	var layers = map_data["layers"]
	for l in layers:
		var layer_map = TileMap.new()
		tilemap_root.add_child(layer_map)
		layer_map.set_opacity(l["opacity"])
		layer_map.set_owner(tilemap_root)
		layer_map.set_name(l["name"])
		layer_map.set_cell_size(cell_size)
		print(l.keys())
		if (l.has("properties")):
			print(l["properties"].keys())
		if (l.has("properties") and l["properties"].has("collidable") and l["properties"]["collidable"]):
			layer_map.set_tileset(tileset)
		else:
			layer_map.set_tileset(tileset)
		var i = 0
		for y in range(0, l["height"]):
			for x in range(0, l["width"]):
				#get the gid as a string first, to prevent rounding error
				var strgid = str(l["data"][i])
				var gid = int(strgid)

				if (gid != 0):
					#read the flags from gid
					var flipped_horizontally = (gid & FLIPPED_HORIZONTALLY_FLAG)
					var flipped_vertically = (gid & FLIPPED_VERTICALLY_FLAG)
					var flipped_diagonally = (gid & FLIPPED_DIAGONALLY_FLAG)

					#clear the flags to get the actual tile id
					gid &= ~(FLIPPED_HORIZONTALLY_FLAG | FLIPPED_VERTICALLY_FLAG | FLIPPED_DIAGONALLY_FLAG)

					layer_map.set_cell(x, y, gid, flipped_horizontally, flipped_vertically)
				i += 1

	#error_popup.set_text("Succesfully imported the map")
	#error_popup.popup()
	return tilemap_root

#func _on_FileDialog_file_selected( path ):
#	map_path = path
