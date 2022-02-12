/* Modified from https://www.shadertoy.com/view/XslGz8, by gtoledo3 */

shader_type canvas_item;

// aberration vars
uniform float dispersion = 1.0;

// warp vars
uniform float distort = 1.0;
uniform float blur_amount = 1.0;


vec2 distortUV( vec2 uv, float level ){
	/* Magic code from shadertoy.com. */
	vec2 centred_uv = uv - 0.5;
	return uv + centred_uv * dot(centred_uv, centred_uv) * level;
}

vec4 barrelBlur( sampler2D tex, vec2 uv, float offset ){
	/* More magic code from the same shadertoy, modified to fit with more parameters. */
	vec4 a1=texture(tex, distortUV(uv,offset+blur_amount*0.0));
	vec4 a2=texture(tex, distortUV(uv,offset+blur_amount*0.2));
	vec4 a3=texture(tex, distortUV(uv,offset+blur_amount*0.4));
	vec4 a4=texture(tex, distortUV(uv,offset+blur_amount*0.6));
	
	vec4 a5=texture(tex, distortUV(uv,offset+blur_amount*0.8));
	vec4 a6=texture(tex, distortUV(uv,offset+blur_amount*1.0));
	vec4 a7=texture(tex, distortUV(uv,offset+blur_amount*1.2));
	vec4 a8=texture(tex, distortUV(uv,offset+blur_amount*1.4));
	
	vec4 a9=texture(tex, distortUV(uv,offset+blur_amount*1.6));
	vec4 a10=texture(tex, distortUV(uv,offset+blur_amount*1.8));
	vec4 a11=texture(tex, distortUV(uv,offset+blur_amount*2.0));
	vec4 a12=texture(tex, distortUV(uv,offset+blur_amount*2.2));
	
	vec4 tx=(a1+a2+a3+a4+a5+a6+a7+a8+a9+a10+a11+a12)/12.;
	
	return vec4(tx.rgb,1.);
}

void fragment() {
	// Splits colors into different variables. First we take a texture with SCREEN_TEXTURE and distortUV (factoring in `dispersion`) and then we combine them into a vec4
	float red = barrelBlur( SCREEN_TEXTURE, SCREEN_UV, distort + dispersion ).r;
	float green = barrelBlur( SCREEN_TEXTURE, SCREEN_UV, distort ).g;
	float blue = barrelBlur( SCREEN_TEXTURE, SCREEN_UV, distort - dispersion ).b;
	COLOR = vec4( red, green, blue, 1.0 );
}