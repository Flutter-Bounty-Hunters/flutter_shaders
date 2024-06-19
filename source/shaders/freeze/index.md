---
description: A shader that simulates a progressive freezing effect, creating a transition from normal to frozen state.
shader:
  title: Freeze
  description: This shader progressively simulates a freezing effect on the screen
  screenshot: freeze.png
  video: freeze.mp4
# For the moment we need to record the path to this directory until Static Shock provides this
directory: shaders/freeze/
---
```glsl
// based on https://www.shadertoy.com/view/MsySzy
// Experiment: Frosted Glass II by Shadmar
// Original by Jack Davenport : https://www.shadertoy.com/view/MtsSWs#

#version 460 core

precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 iResolution;
uniform float progress;
uniform sampler2D image;

out vec4 fragColor;

#define FROSTYNESS 2.0
#define COLORIZE   1.0
#define COLOR_RGB  0.7,1.0,1.0

float rand(vec2 uv) {

    float a = dot(uv, vec2(92., 80.));
    float b = dot(uv, vec2(41., 62.));

    float x = sin(a) + cos(b) * 51.;
    return fract(x);
}

void main( ) {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 d = texture(image, uv);
    vec2 rnd = vec2(rand(uv+d.r*.05), rand(uv+d.b*.05));

    //vignette
    vec2 lensRadius = vec2(progress, 0.05);
    float dist = distance(uv.xy, vec2(0.5,0.5));
    float vigfin = pow(1.-smoothstep(lensRadius.x, lensRadius.y, dist),2.);

    rnd *= .025*vigfin+d.rg*FROSTYNESS*vigfin;
    uv += rnd;
    fragColor = mix(texture(image, uv),vec4(COLOR_RGB,1.0),COLORIZE*vec4(rnd.r));
}
```