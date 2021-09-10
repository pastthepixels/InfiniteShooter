shader_type canvas_item;

uniform float lod: hint_range(0.0, 5) = 0.0;
uniform bool use_custom_color = false;
uniform vec4 custom_color: hint_color = vec4(1.0);
uniform bool darken_custom_color = false;

// From https://godotshaders.com/snippet/blending-modes/
vec4 lighten(vec4 base, vec4 blend){
	return max(base, blend);
}

vec4 overlay(vec4 base, vec4 blend){
	vec4 limit = step(0.5, base);
	return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}



void fragment(){
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV, lod);
	COLOR = color;
	if(use_custom_color == true){
		if(darken_custom_color == false){
			COLOR = lighten(COLOR, custom_color);
		} else {
			COLOR = overlay(COLOR, custom_color);
		}
	}
}

