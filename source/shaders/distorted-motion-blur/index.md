---
description: A shader that simulates motion blur and adds a distortion effect when scrolling on the screen.
shader:
  title: Distorted Motion Blur
  description: "This shader simulates a motion blur effect with a distortion effect when scrolling. You can find an example implementation of the shader in Flutter here: https://github.com/vgtle/shader_studio/tree/main."
  screenshot: distorted-motion-blur.png
  video: distorted-motion-blur.mp4
# For the moment we need to record the path to this directory until Static Shock provides this
directory: shaders/distorted-motion-blur/
---
```glsl
# version 460 core
# include <flutter/runtime_effect.glsl>

uniform vec2 u_size;
uniform vec2 u_velocity;
uniform sampler2D u_texture;

out vec4 frag_color;

void main() {
    
    float q = 24.0;
    vec2 p = FlutterFragCoord().xy / u_size ; 
    vec2 v = u_velocity/ u_size / 2;

    float o = -pow(p.y * 2 - 1, 6) + 1;
    vec4 new_p = vec4(0);
    for (int i = 0; i < q; i++) {
        new_p += texture(u_texture, vec2(p.x +   (( (o - 1) * length(v.y) * 6 *  ((p.x  - 0.5))) ) + (v.x * i) / q, p.y + 0.01 + (v.y * i) / q));
    }
    new_p /= q;
    frag_color = new_p;
}

```