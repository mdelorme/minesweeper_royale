shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform float alpha = 0.0;

void fragment() {
	vec4 color = texture(screen_texture, UV);
	float grey = max(max(color.x, color.y), color.z);
	COLOR = vec4(grey, grey, grey, alpha);
}
