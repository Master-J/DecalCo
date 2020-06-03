shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_back, depth_test_disable;

uniform sampler2D border_mask : hint_white;

uniform sampler2D albedo : hint_albedo;
uniform vec4 albedo_tint : hint_color = vec4(1.0);

uniform sampler2D emission : hint_black;
uniform vec4 emission_tint : hint_color = vec4(vec3(0.0), 1.0);
uniform float emission_strength = 1.0;

uniform sampler2D occlusion : hint_white;
uniform float occlusion_strength = 1.0;

uniform sampler2D specular : hint_white;
uniform float specular_strength = 1.0;

uniform sampler2D metallic : hint_black;
uniform float metallic_strength = 1.0;

uniform sampler2D normal_map : hint_normal;

uniform int current_frame = 0;
uniform int flipbook_columns_count = 1;

uniform float current_frame_blend = 0.0;

uniform bool use_normal_map = false;

uniform vec3 decal_position;
uniform vec3 decal_right;
uniform vec3 decal_up;
uniform vec3 decal_forward;
uniform vec3 decal_half_scale;

//Checks if the given point is in the decal's boundaries using an oriented bounding box defined by the decal's tranform
bool is_point_in_decal_bounds(vec3 point)
{
	vec3 scale = decal_half_scale * 2.0;
	vec3 p = point - decal_position;
	return abs(dot(p, decal_right)) <= scale.x && abs(dot(p, decal_forward)) <= scale.y && abs(dot(p, decal_up)) <= scale.z;
}


void vertex()
{
	//Override the projector mesh's normals in order to render the decal with mostly correct lighting
	NORMAL = (vec4(decal_up, 0.0) * WORLD_MATRIX).xyz;
	TANGENT = (vec4(decal_right, 0.0) * WORLD_MATRIX).xyz;
	BINORMAL = (vec4(decal_forward, 0.0) * WORLD_MATRIX).xyz;
}

void fragment ()
{
	//Compute world position using the depth buffer
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	vec4 world = CAMERA_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	vec3 world_position = world.xyz / world.w;

	if(is_point_in_decal_bounds(world_position))
	{
		//If the world position is within the decal's boundaries, we can compute it's uv coordinates
		vec4 local_position = (vec4(world_position - decal_position, 0.0)) * WORLD_MATRIX;

		vec2 flipbook_frame_index = vec2(float(current_frame % flipbook_columns_count), float(current_frame / flipbook_columns_count));
		vec2 frame_size = vec2(1.0/float(flipbook_columns_count));
		vec2 uv_coords = (vec2(local_position.x, -local_position.y)  / (4.0*(decal_half_scale.xy * 2.0 * decal_half_scale.xy))) - vec2(0.5);
		
		//This is used to fix some blending issues on the decal's edges, border mask is a white texture with a 1px transparent border on all sides
		float border_alpha = texture(border_mask, uv_coords).a;
		
		//Offset UVs to handle flipbook animation
		uv_coords = uv_coords / float(flipbook_columns_count);
		uv_coords -= float(flipbook_columns_count - 1) * frame_size - flipbook_frame_index * frame_size;
		
		//Hacky stuff, to get UVs, correct lighting and normal mapping working, i need to get the fragment's local position in the light shader
		//Unfortunately, we can't use varying to pass values between the fragment and light shaders
		//To work around this limitation, i put the data i need in the TRANSMISSION built-in.
		//Also, due to some limitation caused by how this shader works, PBR lighting isn't supported.
		TRANSMISSION = vec3(1.0) - local_position.xyz / 100.0;
		
		ALBEDO = texture(albedo, uv_coords).rgb * albedo_tint.rgb;
		EMISSION = texture(emission, uv_coords).rgb * emission_tint.rgb * emission_strength;
		ALPHA = texture(albedo, uv_coords).a * border_alpha;
	}else{
		ALPHA = 0.0;
	}
}

//taken from http://www.thetenthplanet.de/archives/1180
mat3 cotangent_frame(vec3 N, vec3 p, vec2 uv) 
{ 

	vec3 dp1 = dFdx(p); 
	vec3 dp2 = dFdy(p);
	vec2 duv1 = dFdx(uv); 
	vec2 duv2 = dFdy(uv); 

	vec3 dp2perp = cross( dp2, N ); 
	vec3 dp1perp = cross( N, dp1 ); 
	
	vec3 T = dp2perp * duv1.x + dp1perp * duv2.x; 
	vec3 B = dp2perp * duv1.y + dp1perp * duv2.y; 

	float invmax = inversesqrt( max( dot(T,T), dot(B,B) ) ); 
	return mat3( T * invmax, B * invmax, N ); 
}

vec3 perturb_normal(vec3 N, vec3 V, vec2 texcoord ) 
{ 
	vec3 map = texture(normal_map, texcoord ).rgb; 
	map = map * 255./127. - 128./127.; 
	map.x *= -1.0;
	map.y *= 1.0;
	map.z *= -1.0;
	mat3 TBN = cotangent_frame(N, V, texcoord); 
	return normalize(TBN * map);
}

void light () 
{
	//Get back the data from the fragment shader
	vec3 data = (vec3(1.0) - TRANSMISSION) * 100.0;
	
	//Recompute UV coordinates
	vec2 uv_coords = vec2(data.x, -data.y);

	vec2 flipbook_frame_index = vec2(float(current_frame % flipbook_columns_count), float(current_frame / flipbook_columns_count));
	vec2 frame_size = vec2(1.0/float(flipbook_columns_count));
	uv_coords = (uv_coords.xy / (4.0*(decal_half_scale.xy * 2.0 * decal_half_scale.xy))) - vec2(0.5);
	uv_coords = uv_coords / float(flipbook_columns_count);
	uv_coords -= float(flipbook_columns_count - 1) * frame_size - flipbook_frame_index * frame_size;

	//Normal mapping
	vec3 normal = NORMAL;
	if(use_normal_map == true)
	{
		normal = perturb_normal(NORMAL, VIEW, uv_coords);
	}

	float n_dot_l = clamp(dot(normal, LIGHT), 0.0, 1.0);
	
	//Specular lighting
	vec3 view_dir = normalize(CAMERA_MATRIX[3].xyz - data);
	vec3 reflection_dir = reflect(-LIGHT, normal);
	float spec = pow(max(dot(view_dir, reflection_dir), 0.0), 32);
	vec3 specular_light = specular_strength * spec * LIGHT_COLOR;  
	
	//Diffuse lighting
	vec3 albedo_color = ALBEDO * n_dot_l;
	albedo_color = albedo_color * mix(1.0, texture(occlusion, uv_coords).r, occlusion_strength);
	
	DIFFUSE_LIGHT += albedo_color * ATTENUATION * LIGHT_COLOR;
	SPECULAR_LIGHT = specular_light * texture(specular, uv_coords).r;
}
