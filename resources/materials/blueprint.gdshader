shader_type canvas_item;

uniform vec4 bg_top : source_color = vec4(0.02, 0.10, 0.20, 1.0);
uniform vec4 bg_bottom : source_color = vec4(0.005, 0.025, 0.08, 1.0);
uniform vec4 line_color : source_color = vec4(0.35, 0.72, 1.0, 1.0);
uniform float grid_strength = 0.1;
uniform float drawing_strength = 0.1;
uniform float vignette_strength = 0.45;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float grid(vec2 uv, float scale, float thickness) {
	vec2 g = abs(fract(uv * scale) - 0.5);
	return 1.0 - smoothstep(0.0, thickness, min(g.x, g.y));
}

float circle(vec2 uv, vec2 c, float r, float t) {
	return 1.0 - smoothstep(t, t * 2.0, abs(distance(uv, c) - r));
}

float segment(vec2 uv, vec2 a, vec2 b, float t) {
	vec2 pa = uv - a;
	vec2 ba = b - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
	return 1.0 - smoothstep(t, t * 2.0, length(pa - ba * h));
}

void fragment() {
	vec2 uv = UV;
	vec3 col = mix(bg_bottom.rgb, bg_top.rgb, 1.0 - uv.y);

	float g1 = grid(uv, 18.0, 0.018);
	float g2 = grid(uv, 72.0, 0.006);
	col += line_color.rgb * (g1 * grid_strength + g2 * grid_strength * 0.35);

	float d = 0.0;
	d += circle(uv, vec2(0.23, 0.32), 0.16, 0.0025);
	d += circle(uv, vec2(0.78, 0.25), 0.22, 0.0025);
	d += circle(uv, vec2(0.52, 0.72), 0.28, 0.002);
	d += segment(uv, vec2(0.08, 0.78), vec2(0.92, 0.32), 0.002);
	d += segment(uv, vec2(0.12, 0.2), vec2(0.45, 0.45), 0.002);
	d += segment(uv, vec2(0.56, 0.12), vec2(0.88, 0.52), 0.002);
	d += segment(uv, vec2(0.36, 0.88), vec2(0.72, 0.72), 0.002);

	float scan = 0.5 + 0.5 * sin((uv.y + TIME * 0.03) * 180.0);
	col += line_color.rgb * d * drawing_strength * (0.8 + scan * 0.2);

	float dots = step(0.992, hash(floor(uv * vec2(80.0, 45.0))));
	col += line_color.rgb * dots * 0.13;

	float center = smoothstep(0.8, 0.0, distance(uv, vec2(0.5, 0.55)));
	col += line_color.rgb * center * 0.04;

	float vig = smoothstep(0.95, 0.2, distance(uv, vec2(0.5, 0.5)));
	col *= mix(1.0 - vignette_strength, 1.0, vig);

	COLOR = vec4(col, 1.0);
}