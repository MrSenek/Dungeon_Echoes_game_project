shader_type canvas_item;

uniform float lod: hint_range(0.0, 5.0) = 2.0; // Siła rozmycia
uniform vec4 color_tint: source_color = vec4(0.0, 0.0, 0.0, 0.3); // Przyciemnienie

// Pobieramy obraz tego, co jest pod ColorRectem
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	// Pobieramy kolor tła z efektem rozmycia (LOD)
    vec4 color = textureLod(screen_texture, SCREEN_UV, lod);
	
	// Miksujemy rozmyte tło z kolorem przyciemnienia
    COLOR = mix(color, color_tint, color_tint.a);
}