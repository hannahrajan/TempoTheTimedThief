extends Control

#==================ROTATE CIRCLE=================================================
# This script has the object rotate in a circular motion and rotate its children
# around it, ensuring the children stay upright.

@export var base_scale: float = 0.5
@export var front_back_ratio: float = 1.0
@export var side_alpha: float = 0.55
@export var tween_time: float = 0.5

@export var offset_degrees: float = 180
@export var steps_per_tower: int = 8

@onready var sub_control_folder: Control = $Towers
@onready var base_mesh: Polygon2D = $Base

var front_scale = base_scale * front_back_ratio
var back_scale = base_scale

var radius_x: float = 200.0
var radius_y: float = 200.0

var towers: Array[Control] = []
var curr_tower: int = 0
var is_rotating: bool = false

# all scenes - hopefully a better way to grab these
var scene_paths = ["res://assets/scenes/locations/tutorial-the_clock_tower.tscn", 
"res://assets/scenes/locations/demo.tscn"]

func _ready() -> void:
	
	# lock pivot to the center of the viewport
	# you would simply do this for wherever this needs to go!
	var screen_center = get_viewport_rect().size / 2.0
	self.global_position = screen_center

	var tower_index: int = 0
	
	# get all tower nodes
	for child in sub_control_folder.get_children():
		if child is Control:
			towers.append(child)
			child.pivot_offset = child.size * 0.5
		if child is TextureButton && tower_index < scene_paths.size():
			# assign a scene to switch to for each tower
			var scene_path: String = scene_paths[tower_index]
			tower_index += 1
			child.pressed.connect(_on_tower_pressed.bind(scene_path))
	
	# set radii based on base width / height (with scale!)	
	var base_scale = base_mesh.transform.get_scale();
	radius_x = (base_scale.x)
	radius_y = (base_scale.y)
	
	arrange_towers_initially()

# arrange items around the parent's local (0,0) center point once
func arrange_towers_initially() -> void:
	if towers.size() == 0: return
	update_tower_carousel(false)
	set_base_polygon()

# set the base polygon based on the tower locations
func set_base_polygon() -> void:
	var tower_locations: Array[Vector2] = []
	
	# go through all towers...
	for i in towers.size():
		var tower = towers[i] 
		for step in range(steps_per_tower):
			# fractional step value between the current tower (i) and the next tower (i + 1)
			# helps create smooth ellipse
			var fractional_i = float(i) + (float(step) / float(steps_per_tower))
			
			# replicate angle calculation using fractional position
			var progress_ratio = (fractional_i - float(curr_tower)) / float(towers.size())
			var angle = progress_ratio * TAU + (offset_degrees * PI / 180.0)
			
			# get same depth used on towers
			var depth = cos(angle)
			var depth_normalized = inverse_lerp(1.0, -1.0, depth)
			var scale_value = lerp(back_scale, front_scale, depth_normalized)
			
			var x = sin(angle) * radius_x * scale_value
			var y = -depth * radius_y * scale_value

			# factor in depth to get actual location for polygon point
			var true_bottom_center = Vector2(x, y + (tower.size.y * scale_value) * 0.5)
			tower_locations.append(true_bottom_center)
	
	# add polygon points to create polygon mesh
	base_mesh.polygon = PackedVector2Array(tower_locations)
	
	# stretch texture along new space via UV
	if base_mesh.texture:
		var tex_size = base_mesh.texture.get_size()
		var uv_points: PackedVector2Array = PackedVector2Array()
		
		# get total min and max points
		var min_x = tower_locations[0].x
		var max_x = tower_locations[0].x
		var min_y = tower_locations[0].y
		var max_y = tower_locations[0].y
		
		for pt in tower_locations:
			min_x = minf(min_x, pt.x)
			max_x = maxf(max_x, pt.x)
			min_y = minf(min_y, pt.y)
			max_y = maxf(max_y, pt.y)
		
		# error checking - ensure total_width and total_height != 0	
		var total_width = max_x - min_x
		var total_height = max_y - min_y
		
		if total_width == 0: total_width = 1.0
		if total_height == 0: total_height = 1.0
		
		# set UV based on location percentage of poly
		for pt in tower_locations:
			var relative_x = (pt.x - min_x) / total_width
			var relative_y = (pt.y - min_y) / total_height
			uv_points.append(Vector2(relative_x * tex_size.x, relative_y * tex_size.y))
			
		base_mesh.uv = uv_points
		
	# reset transformations
	base_mesh.position = Vector2.ZERO
	base_mesh.rotation = 0.0
	base_mesh.scale = Vector2.ONE
	base_mesh.z_index = -1

func _process(_delta: float) -> void:	
	if is_rotating: return
	
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		rotate_towers(int(direction))

func rotate_towers(direction: int) -> void:
	is_rotating = true
	# update current tower index
	curr_tower = (curr_tower - direction + towers.size()) % towers.size()
	update_tower_carousel(true)

func update_tower_carousel(animated: bool) -> void:
	var tween: Tween = null
	if (animated):
		tween = create_tween()
		tween.set_parallel(true)
		
	for i in towers.size():
		var tower = towers[i]
		var offset = _get_wrapped_offset(i - curr_tower)
		var angle = offset * TAU / float(towers.size()) + offset_degrees * PI / 180
		
		# get same depth used on towers
		var depth = cos(angle)
		var depth_normalized = inverse_lerp(1.0, -1.0, depth)
		var scale_value = lerp(back_scale, front_scale, depth_normalized)
		
		var x = sin(angle) * radius_x * scale_value
		var y = -depth * radius_y * scale_value

		var alpha_value = lerp(side_alpha, 1.0, depth_normalized)
		
		var target_position = Vector2(x, y) - tower.pivot_offset
		var target_scale = Vector2.ONE * scale_value
		
		tower.z_index = int(depth_normalized * 100.0)
		tower.disabled = i != curr_tower
		
		if (animated):
			tween.tween_property(tower, "position", target_position, tween_time)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_OUT)
			tween.tween_property(tower, "scale", target_scale, tween_time)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_OUT)
			tween.tween_property(tower, "modulate:a", alpha_value, tween_time)
		else:
			tower.position = target_position
			tower.scale = target_scale
			tower.modulate.a = alpha_value
	
	if (animated):
		tween.finished.connect(func(): is_rotating = false)

func _get_wrapped_offset(offset: int) -> int:
	var half = floorf(towers.size()) / 2
	if (offset > half):
		offset -= towers.size()
	elif (offset < -half):
		offset += towers.size()
	return offset

# when a tower is pressed, ensure it goes to its corresponding scene
func _on_tower_pressed(target_scene: String) -> void:
	var error = get_tree().change_scene_to_file(target_scene)
	
	if error != OK:
		push_error("Failed to load scene at: " + target_scene)
