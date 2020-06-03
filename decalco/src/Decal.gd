tool
extends MeshInstance
class_name Decal , "../icons/icon_decal.svg"

const DECAL_SHADER : Resource = preload("Decal.shader");
const BORDER_ALPHA_MASK : Texture = preload("alpha_mask.png");

enum PlaybackType {
	LOOP, ONE_SHOT
}

export(Texture)				var albedo					: Texture		setget set_albedo;
export(Color)				var albedo_tint				: Color			= Color.white	setget set_albedo_tint;

export(Texture)				var emission				: Texture		setget set_emission;
export(Color)				var emission_tint			: Color			= Color.black	setget set_emission_tint;
export(float, 0.0, 10.0)	var emission_strength		: float	= 1.0	setget set_emission_strength;

export(Texture)				var occlusion				: Texture		setget set_occlusion;
export(float, 0.0, 1.0)		var occlusion_strength		: float	= 1.0	setget set_occlusion_strength;

export(Texture)				var specular				: Texture		setget set_specular;
export(float, 0.0, 1.0)		var specular_strength		: float	= 1.0	setget set_specular_strength;

export(Texture)				var normal_map				: Texture		setget set_normal_map;

export(PlaybackType)		var flipbook_playback_type	: int	= PlaybackType.LOOP;
export(int)					var flipbook_current_frame	: int	= 0		setget set_flipbook_current_frame;
export(int)					var flipbook_columns_count	: int	= 1		setget set_flipbook_columns_count;
export(int)					var flipbook_fps			: int	= 1;
export(bool)				var flipbook_play			: bool	= false;

var _use_normal_map : bool = false;
var _clock : float = 0.0;
var decal_material : Material = null;

func _init() -> void :
	#Instantiate the decal's projector mesh and it's decal material
	mesh = CubeMesh.new();
	cast_shadow = false;
	
	decal_material = ShaderMaterial.new();
	decal_material.shader = DECAL_SHADER;

	set("material/0", decal_material);
	decal_material.render_priority = -1;	#Needed in order to make the decal render behind transparent geometry

func _ready() -> void :
	decal_material.set_shader_param("border_mask", BORDER_ALPHA_MASK);
	decal_material.set_shader_param("albedo", albedo);
	decal_material.set_shader_param("albedo_tint", albedo_tint);
	decal_material.set_shader_param("emission", emission);
	decal_material.set_shader_param("emission_tint", emission_tint);
	decal_material.set_shader_param("occlusion", occlusion);
	decal_material.set_shader_param("specular", specular);
	decal_material.set_shader_param("normal_map", normal_map);
	decal_material.set_shader_param("use_normal_map", _use_normal_map);
	decal_material.set_shader_param("emission_strength", emission_strength);
	decal_material.set_shader_param("occlusion_strength", occlusion_strength);
	decal_material.set_shader_param("specular_strength", specular_strength);
	decal_material.set_shader_param("current_frame", flipbook_current_frame);
	decal_material.set_shader_param("flipbook_columns_count", flipbook_columns_count);
	decal_material.set_shader_param("decal_position", global_transform.origin);
	decal_material.set_shader_param("decal_right", global_transform.basis.x.normalized());
	decal_material.set_shader_param("decal_up", global_transform.basis.y.normalized());
	decal_material.set_shader_param("decal_forward", -global_transform.basis.z.normalized());
	decal_material.set_shader_param("decal_half_scale", scale / 2.0);

func set_albedo(new_albedo : Texture) -> void : 
	albedo = new_albedo;
	decal_material.set_shader_param("albedo", albedo);

func set_albedo_tint(new_albedo_tint : Color) -> void : 
	albedo_tint = new_albedo_tint;
	decal_material.set_shader_param("albedo_tint", albedo_tint);

func set_emission(new_emission : Texture) -> void : 
	emission = new_emission;
	decal_material.set_shader_param("emission", emission);

func set_emission_tint(new_emission_tint : Color) -> void : 
	emission_tint = new_emission_tint;
	decal_material.set_shader_param("emission_tint", emission_tint);

func set_occlusion(new_occlusion : Texture) -> void : 
	occlusion = new_occlusion;
	decal_material.set_shader_param("occlusion", occlusion);

func set_specular(new_specular : Texture) -> void : 
	specular = new_specular;
	decal_material.set_shader_param("specular", specular);

func set_normal_map(new_normal_map : Texture) -> void : 
	normal_map = new_normal_map;
	decal_material.set_shader_param("normal_map", normal_map);

func set_emission_strength(new_emission_strength : float) -> void :
	emission_strength = new_emission_strength;
	decal_material.set_shader_param("emission_strength", emission_strength);

func set_occlusion_strength(new_occlusion_strength : float) -> void :
	occlusion_strength = new_occlusion_strength;
	decal_material.set_shader_param("occlusion_strength", occlusion_strength);

func set_specular_strength(new_specular_strength : float) -> void : 
	specular_strength = new_specular_strength;
	decal_material.set_shader_param("specular_strength", specular_strength);

func set_flipbook_current_frame(new_flipbook_current_frame : int) -> void :
	flipbook_current_frame = new_flipbook_current_frame;
	if flipbook_current_frame >= flipbook_columns_count * flipbook_columns_count :
		flipbook_current_frame = 0;
	elif flipbook_current_frame < 0 :
		flipbook_current_frame = (flipbook_columns_count * flipbook_columns_count) - 1;
	decal_material.set_shader_param("current_frame", flipbook_current_frame);

func set_flipbook_columns_count(new_flipbook_columns_count : int) -> void :
	flipbook_columns_count = max(new_flipbook_columns_count, 1);
	decal_material.set_shader_param("flipbook_columns_count", flipbook_columns_count);
	
func set_flipbook_play (new_flipbook_play : bool) -> void :
	if new_flipbook_play == false :
		flipbook_play = false;
	else :
		flipbook_play = true;
		flipbook_current_frame = 0;

func _process(delta : float) -> void :
	decal_material.set_shader_param("decal_position", global_transform.origin);
	decal_material.set_shader_param("decal_right", global_transform.basis.x.normalized());
	decal_material.set_shader_param("decal_up", global_transform.basis.z.normalized());
	decal_material.set_shader_param("decal_forward", global_transform.basis.y.normalized());
	decal_material.set_shader_param("decal_half_scale", scale / 2.0);

	if normal_map == null :
		decal_material.set_shader_param("use_normal_map", false);
	else :
		decal_material.set_shader_param("use_normal_map", true);

	if flipbook_play :
		_clock += delta;
		if _clock >= (1.0 / flipbook_fps) :
			_clock = 0.0;
			set_flipbook_current_frame(flipbook_current_frame + 1);
			if flipbook_playback_type == PlaybackType.ONE_SHOT && (flipbook_current_frame >= (flipbook_columns_count * flipbook_columns_count) - 1) :
				flipbook_play = false;
