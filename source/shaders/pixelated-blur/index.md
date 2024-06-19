---
description: A shader that combines a simple box blur with pixelation, famously used in the iOS Instagram app.
shader:
  title: Pixelated Blur
  description: An pixelated blur effect.
  screenshot: pixelated-blur.png
  video: pixelated-blur.mp4
# For the moment we need to record the path to this directory until Static Shock provides this
directory: shaders/pixelated-blur/
---
```glsl
#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 iResolution;
uniform sampler2D uTexture;

const int samples = 15;
const float pixelSize = 5;
const float radius = 10.0;


out vec4 FragColor;

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord/iResolution.xy;
    vec2 pixelatedUV = floor(uv * iResolution.xy / pixelSize) * pixelSize / iResolution.xy;

    vec3 col = vec3(0.0);
    for(int x = -samples/2; x <= samples/2; x++)
    {
        for(int y = -samples/2; y <= samples/2; y++)
        {
            vec2 samplePos = pixelatedUV + vec2(x, y) * (radius / iResolution.xy);
            col += texture(uTexture, samplePos).rgb;
        }
    }

    col /= float((samples + 1) * (samples + 1));

    FragColor = vec4(col,1.0);
}
```