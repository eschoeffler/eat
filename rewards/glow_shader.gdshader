shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.75, 0.85, 1.0);
uniform float speed = 3.0;
uniform float min_alpha = 0.3;
uniform float max_alpha = 0.9;

void fragment() {
	float dist = distance(UV, vec2(0.5));
	float circle = smoothstep(0.5, 0.0, dist);
	
	float pulse = min_alpha + (max_alpha - min_alpha) * (0.5 * sin(TIME * speed) + 0.5);
	COLOR = vec4(glow_color.rgb, circle * pulse);
}
