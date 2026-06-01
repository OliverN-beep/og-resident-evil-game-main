extends Node2D

# This script procedurally generates a 2D map composed of prebuilt "room" scenes.
# It creates a main path from a start to an exit room, optionally populates extra rooms,
# and then instantiates corresponding room scenes inside a container Node2D.

@onready var foreground: TileMapLayer = $foreground
@onready var rooms_container: Node2D = $rooms

# Number of rooms horizontally
@export var Width: int = 4
# Number of rooms vertically
@export var Height: int = 4
# Whether to visualise generation (debugging)
@export var visualise_generation := false
# Delay between generation steps
@export var generation_delay := 0.02
# Preload player spawner scene
var player_spawner_scene: PackedScene = preload("res://content/entities/player/player.tscn")

# Room constants
const ROOM_WIDTH: int = 320
const ROOM_HEIGHT: int = 320

# Enum for readability
enum RoomType { EMPTY, START, LR, LRB, LRT, LRBT, EXIT }

enum Door { LEFT = 1, RIGHT = 2, TOP = 4, BOTTOM = 8 }

# Preload scenes
const ROOM_SCENES := {
	# YELLOW: Entrance
	RoomType.START: preload("res://content/level gen/rooms/entrance.tscn"),
	# BLUE: Left-Right
	RoomType.LR: preload("res://content/level gen/rooms/left_right.tscn"),
	# GREEN: Left-Right-Bottom
	RoomType.LRB: preload("res://content/level gen/rooms/left_right_bottom.tscn"),
	# BROWN: Left-Right_Top
	RoomType.LRT: preload("res://content/level gen/rooms/left_right_top.tscn"),
	# PURPLE: Left-Right-Bottom-Top
	RoomType.LRBT: preload("res://content/level gen/rooms/left_right_bottom_top.tscn"),
	# RED: Exit
	RoomType.EXIT: preload("res://content/level gen/rooms/exit.tscn"),
	# GREY: Fill
	RoomType.EMPTY: preload("res://content/level gen/rooms/empty.tscn"),
}

# State variables
var map: Array = [] # map[y][x] = door bitmask
var start_position_x := 0
var start_position_y := 0
var player_spawn_position: Vector2 = Vector2.ZERO
var rng := RandomNumberGenerator.new()

# Signals
signal mapGenerated
signal extraRoomsPlaced
signal mapDrawn

func _ready():
	rng.randomize()
	if Width <= 0 or Height <= 0:
		push_error("Width and Height must be greater than 0.")
		return
	
	foreground.clear()
	
	generate_path()
	place_extra_rooms()
	instantiate_map()
	spawn_player()
	
	print("-- GENERATION COMPLETE --")

# -----------------------------
# PATH GENERATION
# -----------------------------
func generate_path() -> void:
	# Initialise map as EMPTY
	map.clear()
	for y in range(Height):
		map.append([])
		for x in range(Width):
			map[y].append(RoomType.EMPTY)
	
	# Start at top row, random X
	start_position_x = rng.randi_range(0, Width - 1)
	start_position_y = 0
	map[start_position_y][start_position_x] = RoomType.START
	
	var posX = start_position_x
	var posY = start_position_y
	
	while posY < Height - 1:
		if visualise_generation:
			await get_tree().create_timer(generation_delay).timeout
		
		# Horizontal wandering
		var horizontal_moves = rng.randi_range(1, 3)
		for i in range(horizontal_moves):
			var direction = -1 if rng.randi_range(0, 1) == 0 else 1
			var nextX = clamp(posX + direction, 0, Width - 1)
			if nextX != posX:
				posX = nextX
				if map[posY][posX] == RoomType.EMPTY:
					map[posY][posX] = RoomType.LR  # mark horizontal connection
		
		# Move down
		posY += 1
		
		# Update vertical connections
		var above = map[posY - 1][posX]
		if above == RoomType.START:
			map[posY - 1][posX] = RoomType.LRB
		elif above == RoomType.LR:
			map[posY - 1][posX] = RoomType.LRB
		elif above == RoomType.LRT:
			map[posY - 1][posX] = RoomType.LRBT
		elif above == RoomType.EMPTY:
			map[posY - 1][posX] = RoomType.LRB
		
		# Set current room's top connection
		if map[posY][posX] == RoomType.EMPTY:
			map[posY][posX] = RoomType.LRT
		elif map[posY][posX] == RoomType.LR:
			map[posY][posX] = RoomType.LRBT
	
	# Mark final bottom room as EXIT
	map[posY][posX] = RoomType.EXIT
	
	emit_signal("mapGenerated")
	_debug_print_map()

# -----------------------------
# PLACE EXTRA ROOMS (OPTIONAL)
# -----------------------------
func place_extra_rooms() -> void:
	for y in range(Height):
		for x in range(Width):
			# Never overwrite the start room
			if x == start_position_x and y == start_position_y:
				continue
			if map[y][x] == RoomType.EMPTY and rng.randi_range(1, 10) <= 3:
				var top = get_room(x, y - 1)
				var bottom = get_room(x, y + 1)
				
				var new_room = RoomType.LR
				if top != RoomType.EMPTY or bottom != RoomType.EMPTY:
					if top != RoomType.EMPTY and bottom != RoomType.EMPTY:
						new_room = RoomType.LRBT
					elif top != RoomType.EMPTY:
						new_room = RoomType.LRT
					elif bottom != RoomType.EMPTY:
						new_room = RoomType.LRB
				map[y][x] = new_room
	emit_signal("extraRoomsPlaced")

# -----------------------------
# INSTANTIATE MAP
# -----------------------------
func instantiate_map() -> void:
	for y in range(Height):
		for x in range(Width):
			if visualise_generation:
				await get_tree().create_timer(generation_delay).timeout
			
			var scene: PackedScene
			# Always place start scene at start coordinates
			if x == start_position_x and y == start_position_y:
				scene = ROOM_SCENES[RoomType.START]
				player_spawn_position = Vector2(x * ROOM_WIDTH, y * ROOM_HEIGHT)
			else:
				var room_type: RoomType = map[y][x]
				scene = ROOM_SCENES.get(room_type, ROOM_SCENES[RoomType.EMPTY])
			
			place_room(scene, x * ROOM_WIDTH, y * ROOM_HEIGHT)
	
	emit_signal("mapDrawn")

func place_room(scene: PackedScene, offsetX: int, offsetY: int) -> void:
	if scene == null:
		push_error("Failed to load room scene.")
		return
	var instance = scene.instantiate()
	instance.position = Vector2(offsetX, offsetY)
	rooms_container.add_child(instance)

# -----------------------------
# SPAWN PLAYER
# -----------------------------
func spawn_player() -> void:
	if player_spawner_scene == null:
		push_error("Player spawner scene not found!")
		return
	var spawner = player_spawner_scene.instantiate()
	spawner.position = player_spawn_position + Vector2(160,160)
	rooms_container.add_child(spawner)
# -----------------------------
# UTILITY
# -----------------------------
func has_door(x: int, y: int, door: int) -> bool:
	return (get_room(x, y) & door) != 0

func add_door(x: int, y: int, door: int) -> void:
	if not in_bounds(x, y):
		return
	map[y][x] |= door

func connect_rooms(x1: int, y1: int, x2: int, y2: int) -> void:
	if x1 == x2:
		if y2 == y1 - 1:
			add_door(x1, y1, Door.TOP)
			add_door(x2, y2, Door.BOTTOM)
		elif y2 == y1 + 1:
			add_door(x1, y1, Door.BOTTOM)
			add_door(x2, y2, Door.TOP)
	elif y1 == y2:
		if x2 == x1 - 1:
			add_door(x1, y1, Door.LEFT)
			add_door(x2, y2, Door.RIGHT)
		elif x2 == x1 + 1:
			add_door(x1, y1, Door.RIGHT)
			add_door(x2, y2, Door.LEFT)

func in_bounds(x: int, y: int) -> bool:
	return x >= 0 and x < Width and y >= 0 and y < Height

func get_room(x: int, y: int) -> int:
	if in_bounds(x, y):
		return map[y][x]
	return 0

func normalize_map():
	for y in range(Height):
		for x in range(Width):
			var mask = 0
			if has_door(x - 1, y, Door.RIGHT):
				mask |= Door.LEFT
			if has_door(x + 1, y, Door.LEFT):
				mask |= Door.RIGHT
			if has_door(x, y - 1, Door.BOTTOM):
				mask |= Door.TOP
			if has_door(x, y + 1, Door.TOP):
				mask |= Door.BOTTOM
			map[y][x] = mask

func _debug_print_map() -> void:
	for row in map:
		print(row)
