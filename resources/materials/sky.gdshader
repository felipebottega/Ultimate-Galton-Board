shader_type canvas_item;

uniform vec4 sky_top : source_color = vec4(0.015, 0.02, 0.06, 1.0);
uniform vec4 sky_bottom : source_color = vec4(0.0, 0.0, 0.015, 1.0);

uniform float meteor_count = 18.0;
uniform float meteor_speed = 0.18;
uniform float meteor_length = 0.22;
uniform float meteor_thickness = 0.006;
uniform float meteor_brightness = 2.8;

uniform float star_density = 120.0;
uniform float star_brightness = 0.75;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float hash(float n) {
	return fract(sin(n) * 43758.5453123);
}

float star_field(vec2 uv) {
	vec2 gv = fract(uv * star_density) - 0.5;
	vec2 id = floor(uv * star_density);
	float h = hash(id);
	float d = length(gv);
	float star = smoothstep(0.045, 0.0, d) * step(0.965, h);
	float twinkle = 0.65 + 0.35 * sin(TIME * 2.0 + h * 20.0);
	return star * twinkle;
}

float meteor(vec2 uv, float i) {
	float seed = hash(i * 17.17);

	vec2 dir = normalize(vec2(1.0, 0.42));
	vec2 normal = vec2(-dir.y, dir.x);

	float spacing = 1.0 / meteor_count;
	float lane = fract(i * spacing + seed);

	float t = fract(TIME * meteor_speed * (0.55 + seed * 1.8) + seed);
	vec2 head = vec2(-0.35, -0.2 + lane * 1.4) + dir * t * 1.9;

	vec2 p = uv - head;
	float along = dot(p, dir);
	float across = abs(dot(p, normal));

	float len = meteor_length * (0.55 + seed * 1.25);
	float thick = meteor_thickness * (0.65 + seed * 1.4);

	float trail = smoothstep(len, 0.0, -along) * smoothstep(thick, 0.0, across) * step(along, 0.0);
	float core = smoothstep(thick * 1.25, 0.0, length(p));

	float fade_in = smoothstep(0.0, 0.12, t);
	float fade_out = smoothstep(1.0, 0.78, t);

	return (trail * 0.85 + core * 1.8) * fade_in * fade_out;
}

void fragment() {
	vec2 uv = UV;

	vec3 col = mix(sky_top.rgb, sky_bottom.rgb, uv.y);
	col += vec3(star_field(uv)) * star_brightness;

	float m = 0.0;
	for (float i = 0.0; i < 32.0; i++) {
		if (i >= meteor_count) break;
		m += meteor(uv, i);
	}

	vec3 meteor_color = vec3(0.75, 0.88, 1.0) + vec3(0.45, 0.2, 0.05) * smoothstep(0.5, 2.2, m);
	col += meteor_color * m * meteor_brightness;

	COLOR = vec4(col, 1.0);
}