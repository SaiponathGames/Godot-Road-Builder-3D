shader_type spatial;


uniform vec4 asphalt_color : hint_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform float line_width = 0.03;
uniform float center_line_distance = 0.1;
uniform vec4 center_line_color : hint_color = vec4(1.0);
uniform float edge_line_distance = 0.9;
uniform vec4 edge_line_color : hint_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform int lane_line_amount = 3;
uniform float lane_line_distance = 0.45;
uniform float lane_line_spread = 0.2;
uniform vec4 lane_line_color : hint_color = vec4(1.0);
uniform int lane_line_steeple = 6;
uniform vec2 offset = vec2(0.0, 0.0);

float line(vec2 uv, float width, float position, int steeple) {
    float line = float( abs( uv.x - position ) < line_width / 2.0);
    uv.y -= 0.25 / float(steeple);
    uv.y = fract(float(steeple) * uv.y);
    line *= float(uv.y < 0.5);
    return line;
}

void fragment() {
    vec2 base_uv = UV + offset;
    base_uv.x = abs(base_uv.x * 2.0 - 1.0); // making a mirrored UV
    
    // center lines
    float center_line = line(base_uv, line_width, center_line_distance, 0);
    float edge_line = line(base_uv, line_width, edge_line_distance, 0);
    
    float lane_lines;
    for(int i = 0; i < lane_line_amount; i++) {
        lane_lines += line(base_uv, line_width, lane_line_distance - lane_line_spread / 2.0 + lane_line_spread * float(i) / float(lane_line_amount), lane_line_steeple);
    }
    
    vec4 color = mix(asphalt_color, center_line_color, center_line);
    color = mix(color, edge_line_color, edge_line);
    color = mix(color, lane_line_color, lane_lines);
    
    ALBEDO = color.rgb;
	ALPHA = color.a;
}