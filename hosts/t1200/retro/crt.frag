// Mild full-screen CRT pass for the t1200 (Hyprland decoration.screen_shader).
// Deliberately subtle and static (no `time` uniform), so damage tracking stays
// on and it costs almost nothing. No curvature: the bezel crop would clip it.
#version 300 es

precision mediump float;
in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;
uniform sampler2D tex;

const float SCANLINE   = 0.10;  // darkening of every other row (0 = off)
const float GLOW       = 0.12;  // horizontal phosphor bleed
const float VIGNETTE   = 0.18;  // corner falloff
const float MASK       = 0.03;  // RGB aperture-grille tint per column

void main() {
    vec2 px = 1.0 / vec2(textureSize(tex, 0));
    vec3 c  = texture(tex, v_texcoord).rgb;

    // phosphor bleed: a little of the neighbouring pixels
    vec3 side = texture(tex, v_texcoord + vec2(px.x, 0.0)).rgb
              + texture(tex, v_texcoord - vec2(px.x, 0.0)).rgb;
    c = mix(c, max(c, side * 0.5), GLOW);

    // scanlines
    float row = mod(gl_FragCoord.y, 2.0);
    c *= 1.0 - SCANLINE * step(1.0, row);

    // aperture grille
    int col = int(mod(gl_FragCoord.x, 3.0));
    vec3 mask = vec3(1.0 - MASK);
    mask[col] = 1.0 + MASK;
    c *= mask;

    // vignette
    vec2 d = v_texcoord - 0.5;
    c *= 1.0 - VIGNETTE * dot(d, d) * 2.0;

    fragColor = vec4(c, 1.0);
}
