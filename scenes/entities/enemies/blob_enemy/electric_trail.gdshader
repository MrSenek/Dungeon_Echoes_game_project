shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(0.0, 0.8, 1.0, 1.0);
uniform float speed = 15.0;
uniform float amplitude = 0.2;

// Funkcja pomocnicza do generowania szumu (zygzaka)
float hash(float n) {
	return fract(sin(n) * 43758.5453123);
}

void fragment() {
	vec2 uv = UV;
	
	// Tworzymy "schodkowany" szum na podstawie czasu
	float time_step = floor(TIME * speed);
	float noise = hash(dot(vec2(floor(uv.x * 10.0), time_step), vec2(12.9898, 78.233)));
	
	// Wykrzywiamy linię tylko w pionie
	float dist = abs(uv.y - 0.5 + (noise - 0.5) * amplitude);
	
	// Tworzymy ostrą krawędź (pixel art style)
	float line = step(dist, 0.1);
	
	vec4 final_color = line_color * line;
	
	// Sprawiamy, że końce linii zanikają
	final_color.a *= pow(1.0 - abs(uv.x - 0.5) * 2.0, 2.0);
	
	COLOR = final_color;
}