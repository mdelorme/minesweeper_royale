shader_type canvas_item;

uniform vec4 color1: source_color;
uniform vec4 color2: source_color;
uniform vec2 scroll_speed = vec2(1.,-1);
uniform float scale = 1.;

void fragment() {
	vec4 col = texture(TEXTURE,vec2(UV.x,UV.y)*scale+scroll_speed*TIME);
	COLOR = mix(color1,color2,col.r);
}
