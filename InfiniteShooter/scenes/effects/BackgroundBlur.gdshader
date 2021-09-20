//Modified from https://godotshaders.com/shader/chromatic-abberation-with-offset/
shader_type canvas_item;

uniform float lod: hint_range(0.0, 5) = 0.0;

uniform sampler2D offset_image : hint_white;
uniform float aberration_strength = .5;

void fragment(){
	vec4 output = texture(SCREEN_TEXTURE, SCREEN_UV, lod);
	
	float shift = aberration_strength * texture(offset_image, SCREEN_UV, lod).r / 100.0;
	output.r = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x + shift, SCREEN_UV.y), lod).r;
	output.g = texture(SCREEN_TEXTURE, SCREEN_UV, lod).g;
	output.b = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x - shift, SCREEN_UV.y), lod).b;
	
	COLOR = output;	
}

