# Colors

## Flutter Colors

The Color Class in Flutter is a immutable 32 bit color value, with four channels. These channels are namely Alpha, Red, Green and Blue.

Each channel are represented by two hexadecimal numbers, that can represent 255 different values.

    Color(0xAARRGGBB)

AA, returns a color that matches the alpha cannel with a Hexadecimal value.(value between 00 and FF)

RR, returns a color that matches the red cannel with a Hexadecimal value.(value between 00 and FF)

GG, returns a color that matches the green cannel with a Hexadecimal value.(value between 00 and FF)

BB, returns a color that matches the blue cannel with a Hexadecimal value.(value between 00 and FF)

## Conversion from Hexadecimal color to Decimal Color

If we consider the Color(0xFF448AFF), we can deduct the following from each channel.

Alpha - FF represents this channel - if we convert the hexadecimal to decimal.

    (FF)₁₆ = (15 × 16¹) + (15 × 16⁰)  = (255)₁₀

Red - 44 represent this channel - if we convert the hexadecimal to decimal.

    (44)₁₆ = (4 × 16¹) + (4 × 16⁰) = (68)₁₀

Green - 8A represent this channel - if we convert the hexadecimal to decimal.

    (8A)₁₆ = (8 × 16¹) + (10 × 16⁰) = (138)₁₀

Blue - FF represent this channel - if we convert the hexadecimal to decimal.

    (FF)₁₆ = (15 × 16¹) + (15 × 16⁰)  = (255)₁₀

Now from our calculations above we can conclude that Color(0xFF448AFF) can be represented as Color.fromARGB(255, 68, 138, 255).

## GLSL color

In OpenGL Shading Language colors can be stored in floating-point vector variables. For this e use a vec4 myRGBA.

The vec4 using an array of four-component unsigned integer vector.

    vec(r.r, g.g, b.b, a.a)

r.r, returns a color that matches the red cannel with a floating-point vector value.(value between 0.0 and 1.0)

g.g, returns a color that matches the green cannel with a floating-point vector value.(value between 0.0 and 1.0)

b.b, returns a color that matches the blue cannel with a floating-point vector value.(value between 0.0 and 1.0)

a.a, returns a color that matches the alpha cannel with a floating-point vector value.(value between 0.0 and 1.0)

Ref
https://registry.khronos.org/OpenGL/specs/gl/GLSLangSpec.4.40.pdf


## Converting for Hexadecimal color to vec4 Floating point color 

Converting decimal numbers to floating-point the decimal value are divided by 255.

If we consider the Color(0xFF448AFF) can be represented as Color.fromARGB(255, 68, 138, 255) (rom calculation above) we can deduct the following for each channel

Alpah  - 255 represents this channel - if we convert the decimal to floating-point.

    255 / 255 = 1.0

Red  - 68 represents this channel - if we convert the decimal to floating-point.

    68 / 255 = 0,2667

Green  - 138 represents this channel - if we convert the decimal to floating-point.

    138 / 255 = 0,5412

Blue  - 255 represents this channel - if we convert the decimal to floating-point.

    255 / 255 = 1.0

Now from our calculations above we can conclude that Color(0xFF448AFF) can be represented as vec4(0,2667, 0,5412, 1.0, 1.0).

![Hex_GLSL_colour.png](https://github.com/Flutter-Bounty-Hunters/flutter_shaders/tree/main/source/images/Hex_GLSL_colour.png)