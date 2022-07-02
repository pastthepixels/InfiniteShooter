//Modified from https://godotshaders.com/shader/chromatic-abberation-with-offset/
shader_type canvas_item;

uniform float lod: hint_range(0.0, 5) = 0.0;

void fragment(){
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV, lod);
}

