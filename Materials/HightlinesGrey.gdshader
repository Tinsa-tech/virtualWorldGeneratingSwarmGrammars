shader_type spatial;

varying vec3 world_position;
varying float grid_pos;

uniform float line_width : hint_range(0.0, 1.0) = 0.1;
uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 fill_color : source_color = vec4(0.3, 0.3, 0.3, 1.0);
uniform float gridSize = 1;

void vertex() {
	world_position = VERTEX;
}

void fragment(){
	grid_pos = mod(world_position.y, gridSize);
	float line = step(line_width, grid_pos);

	vec3 col = mix(line_color.rgb, fill_color.rgb, line);
	ALBEDO = col;
}