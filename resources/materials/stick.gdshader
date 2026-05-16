shader_type canvas_item;

uniform float seed = 1.0;
uniform float speed : hint_range(0.0, 5.0) = 0.2;
uniform float scale : hint_range(1.0, 20.0) = 1.0;
uniform float intensity : hint_range(0.0, 3.0) = 3.0;
uniform float contrast : hint_range(0.1, 5.0) = 2.0;
uniform float aspect_fix : hint_range(0.1, 20.0) = 20.0;
uniform int particle_count : hint_range(1, 100) = 50;
uniform vec4 color_top : source_color = vec4(0.08, 0.00, 0.00, 1.0);
uniform vec4 color_bottom : source_color = vec4(1.00, 0.08, 0.02, 1.0);

float hash(float n) {
	return fract(sin(n * 12.9898 + seed * 78.233) * 43758.5453);
}

float blob(vec2 p, vec2 center, float radius) {
	float d = length((p - center) * vec2(4.0, aspect_fix));
	return radius / max(d, 0.001);
}

void fragment() {
	vec2 uv = UV;
	vec2 p = (uv - 0.5) * scale;

	float t = TIME * speed;
	float v = 0.0;

	for (int i = 0; i < 100; i++) {
		if (i >= particle_count) { 
			break; 
		}

		float fi = float(i);
		float cycle = scale + 2.0;
		float progress = fract(t * (0.04 + hash(fi * 3.17) * 0.06) + hash(fi * 7.91));
		float y = mix(-scale * 0.5 - 1.0, scale * 0.5 + 1.0, progress);
		float x = (hash(fi * 12.31) - 0.5) * scale;
		float r = 0.18 + hash(fi * 5.43) * 0.22;
		float fade = smoothstep(0.0, 0.18, progress) * smoothstep(1.0, 0.82, progress);

		v += blob(p, vec2(x + sin(t * 0.7 + fi) * 0.35, -y), r) * fade;
	}

	v = pow(v * 0.28, contrast);
	v *= intensity;
	vec4 color = mix(color_bottom, color_top, smoothstep(0.15, 1.2, v));
	COLOR = color;
}