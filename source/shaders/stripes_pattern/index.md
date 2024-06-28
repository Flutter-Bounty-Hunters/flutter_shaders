---
description: A shader that creates a stripes pattern with warp effect.
shader:
  title: Stripes Pattern
  description: Creates a stripes pattern with warp effect with ability to customize different charactersistics of the pattern like warping, speed, direction, colors, etc.
  screenshot: stripes_pattern.png
  video: stripes_pattern.mp4
# For the moment we need to record the path to this directory until Static Shock provides this
directory: shaders/stripes_pattern/
---
```glsl
// Author: Rutvik Tak
// Flutter example: https://github.com/rutvik110/Flutter-Animations/tree/master/lib/flutter_shaders/stripes_shader

#define PI 3.14159265359
uniform float width;
uniform float height;
uniform float u_time;
uniform float tiles;
uniform float speed;
uniform float direction;
uniform float warpScale;
uniform float warpTiling;
uniform vec3 color1;
uniform vec3 color2;

vec2 iResolution=vec2(width,height);

out vec4 fragColor;

vec2 rotatePoint(vec2 pt,vec2 center,float angle){
    float sinAngle=sin(angle);
    float cosAngle=cos(angle);
    pt-=center;
    vec2 r=vec2(1.);
    r.x=pt.x*cosAngle-pt.y*sinAngle;
    r.y=pt.x*sinAngle+pt.y*cosAngle;
    r+=center;
    return r;
}

void main(){
    vec2 uv=gl_FragCoord.xy/iResolution.xy;
    
    vec2 uv2=rotatePoint(uv.xy,vec2(.5,.5),direction*2.*PI);
    
    uv2.x+=sin(uv2.y*warpTiling*PI*2.)*warpScale+speed;
    uv2.x*=tiles;
    
    float st=floor(fract(uv2.x)+.5);
    
    vec3 color=mix(color1,color2,st);
    
    fragColor=vec4(color,1.);
}
```