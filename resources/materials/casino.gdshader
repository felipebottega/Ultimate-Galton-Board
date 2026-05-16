shader_type canvas_item;

uniform vec4 bg_top : source_color = vec4(0.08, 0.0, 0.08, 1.0);
uniform vec4 bg_bottom : source_color = vec4(0.015, 0.0, 0.025, 1.0);
uniform vec4 gold : source_color = vec4(1.0, 0.62, 0.12, 1.0);
uniform vec4 red_neon : source_color = vec4(1.0, 0.02, 0.02, 1.0);
uniform vec4 blue_neon : source_color = vec4(0.05, 0.45, 1.0, 1.0);
uniform float bulb_strength = 0.55;
uniform float neon_strength = 0.45;
uniform float vignette_strength = 0.55;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float circle(vec2 uv, vec2 c, float r, float blur) {
	return 1.0 - smoothstep(r, r + blur, distance(uv, c));
}

float segment(vec2 uv, vec2 a, vec2 b, float t) {
	vec2 pa = uv - a;
	vec2 ba = b - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
	return 1.0 - smoothstep(t, t * 3.0, length(pa - ba * h));
}

void fragment() {
	vec2 uv = UV;
	vec3 col = mix(bg_bottom.rgb, bg_top.rgb, 1.0 - uv.y);

	float side = smoothstep(0.45, 0.0, abs(uv.x - 0.5));
	col += vec3(0.10, 0.0, 0.08) * side;

	float neon = 0.0;
	neon += segment(uv, vec2(0.06, 0.1), vec2(0.22, 0.9), 0.006);
	neon += segment(uv, vec2(0.94, 0.1), vec2(0.78, 0.9), 0.006);
	neon += segment(uv, vec2(0.18, 0.12), vec2(0.82, 0.12), 0.004);
	col += red_neon.rgb * neon * neon_strength;

	float bulbs = 0.0;
	for (float i = 0.0; i < 18.0; i++) {
		float y = 0.08 + i * 0.052;
		float f = 0.65 + 0.35 * sin(TIME * 3.0 + i * 1.7);
		bulbs += circle(uv, vec2(0.035, y), 0.008, 0.018) * f;
		bulbs += circle(uv, vec2(0.965, y), 0.008, 0.018) * f;
	}

	for (float i = 0.0; i < 16.0; i++) {
		float x = 0.12 + i * 0.052;
		float f = 0.65 + 0.35 * sin(TIME * 2.5 + i * 2.1);
		bulbs += circle(uv, vec2(x, 0.055), 0.007, 0.016) * f;
	}

	col += gold.rgb * bulbs * bulb_strength;

	float bokeh = 0.0;
	for (float i = 0.0; i < 24.0; i++) {
		vec2 p = vec2(hash(vec2(i, 1.0)), hash(vec2(i, 2.0)));
		float r = 0.012 + hash(vec2(i, 3.0)) * 0.035;
		float f = 0.4 + 0.6 * sin(TIME * (0.6 + hash(vec2(i, 4.0))) + i);
		bokeh += circle(uv, p, r, r * 1.7) * f;
	}
	col += mix(red_neon.rgb, blue_neon.rgb, uv.x) * bokeh * 0.08;

	float center_glow = smoothstep(0.75, 0.0, distance(uv, vec2(0.5, 0.52)));
	col += gold.rgb * center_glow * 0.08;

	float vig = smoothstep(0.95, 0.25, distance(uv, vec2(0.5, 0.5)));
	col *= mix(1.0 - vignette_strength, 1.0, vig);

	COLOR = vec4(col, 1.0);
}