tool
extends MeshInstance

# use this script on one shot flipbook animations

func _ready():
	var cur_time = OS.get_ticks_msec() / 1000.0
	var mat = get_surface_material(0).duplicate(true)
	set_surface_material(0, mat)
	mat.set_shader_param("start_time", cur_time)
	
