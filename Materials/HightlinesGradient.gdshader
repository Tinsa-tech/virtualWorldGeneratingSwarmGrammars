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

vec3 hsv2rgb(vec3 _c) {
    vec4 _K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 _p = abs(fract(_c.xxx + _K.xyz) * 6.0 - _K.www);
    return _c.z * mix(_K.xxx, clamp(_p - _K.xxx, 0.0, 1.0), _c.y);
}

void fragment(){
	vec3 gradient = hsv2rgb(vec3(mod(world_position.y / 20.0, 1.0), 1.0, 1.0));
	grid_pos = mod(world_position.y, gridSize);
	float line = step(line_width, grid_pos);

	vec3 col = mix(line_color.rgb, gradient, line);
	ALBEDO = col;
}