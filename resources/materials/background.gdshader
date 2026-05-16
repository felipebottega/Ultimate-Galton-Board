shader_type canvas_item;

uniform vec4 sky_top : source_color = vec4(0.015, 0.035, 0.08, 1.0);
uniform vec4 sky_mid : source_color = vec4(0.025, 0.10, 0.18, 1.0);
uniform vec4 sky_bottom : source_color = vec4(0.03, 0.13, 0.10, 1.0);

uniform vec4 tree_near : source_color = vec4(0.01, 0.035, 0.025, 1.0);
uniform vec4 tree_far : source_color = vec4(0.015, 0.06, 0.055, 1.0);
uniform vec4 firefly_color : source_color = vec4(1.0, 0.82, 0.35, 1.0);

uniform float wind_speed = 0.7;
uniform float wind_strength = 0.035;
uniform float tree_amount = 1.0;
uniform float firefly_amount = 0.45;
uniform float mist_amount = 0.28;
uniform float vignette_strength = 0.45;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 5; i++) {
		v += noise(p) * a;
		p *= 2.0;
		a *= 0.5;
	}
	return v;
}

float circle(vec2 uv, vec2 c, float r, float blur) {
	return 1.0 - smoothstep(r, r + blur, distance(uv, c));
}

float segment(vec2 uv, vec2 a, vec2 b, float t) {
	vec2 pa = uv - a;
	vec2 ba = b - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
	return 1.0 - smoothstep(t, t * 2.4, length(pa - ba * h));
}

float canopy(vec2 uv, float layer, float offset) {
	vec2 p = uv;
	float sway = sin(TIME * wind_speed + p.y * 9.0 + offset) * wind_strength * layer;
	p.x += sway * smoothstep(0.38, 1.0, p.y);

	float base = 0.50 + layer * 0.12 + fbm(vec2(p.x * 4.0 + offset, 0.0)) * 0.18;
	float mass = smoothstep(base + 0.08, base - 0.02, p.y);

	float leaves = fbm(p * vec2(10.0, 7.0) + vec2(offset, TIME * 0.05));
	leaves = smoothstep(0.36, 0.78, leaves);

	return mass * leaves;
}

float trunks(vec2 uv, float layer, float offset) {
	float t = 0.0;

	for (float i = 0.0; i < 9.0; i++) {
		float x = fract(i * 0.137 + offset);
		float h = 0.42 + hash(vec2(i, offset)) * 0.25;
		float w = mix(0.004, 0.012, hash(vec2(i, offset + 9.0))) * layer;

		float sway = sin(TIME * wind_speed + i * 1.8 + uv.y * 7.0) * wind_strength * 0.45 * layer;
		vec2 root = vec2(x, 1.05);
		vec2 top = vec2(x + sway, 1.0 - h);

		t += segment(uv, root, top, w);

		vec2 b1 = mix(root, top, 0.45);
		vec2 b2 = b1 + vec2(0.05 + hash(vec2(i, 1.0)) * 0.08, -0.10 - hash(vec2(i, 2.0)) * 0.12);
		vec2 b3 = b1 + vec2(-0.05 - hash(vec2(i, 3.0)) * 0.08, -0.09 - hash(vec2(i, 4.0)) * 0.10);

		t += segment(uv, b1, b2, w * 0.45);
		t += segment(uv, b1, b3, w * 0.38);
	}

	return t;
}

float grass(vec2 uv) {
	float g = 0.0;
	for (float i = 0.0; i < 34.0; i++) {
		float x = fract(i * 0.379);
		float h = 0.025 + hash(vec2(i, 2.0)) * 0.06;
		float sway = sin(TIME * wind_speed * 1.4 + i * 0.8) * wind_strength * 0.25;
		g += segment(uv, vec2(x, 1.02), vec2(x + sway, 1.0 - h), 0.0015);
	}
	return g;
}

float fireflies(vec2 uv) {
	float f = 0.0;

	for (float i = 0.0; i < 18.0; i++) {
		float seed = hash(vec2(i, 4.0));
		vec2 p = vec2(hash(vec2(i, 1.0)), 0.40 + hash(vec2(i, 2.0)) * 0.50);
		p.x += sin(TIME * (0.25 + seed * 0.45) + i) * 0.035;
		p.y += cos(TIME * (0.18 + seed * 0.35) + i * 2.0) * 0.025;

		float blink = pow(0.5 + 0.5 * sin(TIME * (1.2 + seed * 2.0) + i * 4.0), 4.0);
		f += circle(uv, p, 0.0025, 0.018) * blink;
	}

	return f;
}

void fragment() {
	vec2 uv = UV;

	vec3 col = mix(sky_bottom.rgb, sky_mid.rgb, smoothstep(1.0, 0.25, uv.y));
	col = mix(col, sky_top.rgb, smoothstep(0.45, 0.0, uv.y));

	float sky_noise = fbm(uv * vec2(2.0, 3.0) + vec2(0.0, TIME * 0.015));
	col += vec3(0.015, 0.025, 0.025) * sky_noise;

	float mist = fbm(vec2(uv.x * 3.0 + TIME * 0.035, uv.y * 8.0));
	mist *= smoothstep(1.0, 0.45, uv.y) * smoothstep(0.25, 0.85, uv.y);
	col += vec3(0.10, 0.16, 0.14) * mist * mist_amount;

	float far_canopy = canopy(uv, 0.55, 2.3);
	float far_trunks = trunks(uv, 0.55, 0.31);
	col = mix(col, tree_far.rgb, smoothstep(0.05, 0.85, clamp((far_canopy + far_trunks) * 0.75 * tree_amount, 0.0, 1.0)));

	float near_canopy = canopy(uv, 1.0, 7.1);
	float near_trunks = trunks(uv, 1.0, 0.73);
	col = mix(col, tree_near.rgb, clamp((near_canopy + near_trunks) * tree_amount, 0.0, 1.0));

	float gr = grass(uv);
	col = mix(col, tree_near.rgb * 1.25, clamp(gr * 0.8, 0.0, 1.0));

	float ff = fireflies(uv);
	col += firefly_color.rgb * ff * firefly_amount;

	float moon = circle(uv, vec2(0.82, 0.16), 0.055, 0.035);
	col += vec3(0.20, 0.24, 0.20) * moon * 0.35;

	float vig = smoothstep(0.95, 0.18, distance(uv, vec2(0.5, 0.52)));
	col *= mix(1.0 - vignette_strength, 1.0, vig);

	COLOR = vec4(col, 1.0);
}