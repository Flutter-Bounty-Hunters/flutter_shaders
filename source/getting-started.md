---
title: Getting Started with Flutter Shaders
description: Learn how to create stunning visual effects and performant graphics directly in your 
    Flutter applications with this comprehensive guide.
layout: layouts/content_page.jinja
directory: getting-started/
---

# Getting Started with Flutter Shaders

Shaders in Flutter allow you to create stunning visual effects and performant graphics directly in 
your Flutter applications. This guide will take you from basic concepts to implementing real shader 
effects in your apps.

## Integrating Shaders from FlutterShaders.com
TL;DR: To use a shader from this website:

1. **Copy the shader code** from the shader page
2. **Save it** as a `.frag` file in `assets/shaders/`
3. **Add it to your pubspec.yaml** under `flutter: shaders:`
4. **Identify the uniforms** the shader expects
5. **Create a CustomPainter** similar to the example above
6. **Set the required uniforms** in the `paint` method

## Step-by-Step Setup
Follow these steps to create your first Flutter shader project:

#### Step 1: Create a New Flutter Project

```bash
flutter create my_shader_app
cd my_shader_app
```

#### Step 2: Create the Assets Directory Structure

```bash
mkdir -p assets/shaders
```

#### Step 3: Create Your First Shader File
Create a file `assets/shaders/animated_colors.frag` with the following content:

```glsl
#include <flutter/runtime_effect.glsl>

uniform vec2 iResolution;
uniform float iTime;

out vec4 fragColor;

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    
    // Normalize coordinates (0.0 to 1.0)
    vec2 uv = fragCoord / iResolution.xy;
    
    // Create animated colors
    vec3 color = vec3(
        0.5 + 0.5 * cos(iTime + uv.x * 6.0),
        0.5 + 0.5 * cos(iTime + uv.y * 6.0 + 2.0),
        0.5 + 0.5 * cos(iTime + uv.x * 6.0 + 4.0)
    );
    
    fragColor = vec4(color, 1.0);
}
```

#### Step 4: Register the Shader in pubspec.yaml
Add the shader to your `pubspec.yaml` file:

```yaml
flutter:
  uses-material-design: true
  shaders:
    - assets/shaders/animated_colors.frag
```

#### Step 5: Create the Flutter Application

Replace the contents of `lib/main.dart` with:

```dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Shader Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AnimatedColorsDemo(),
    );
  }
}

class AnimatedColorsDemo extends StatefulWidget {
  const AnimatedColorsDemo({super.key});

  @override
  State<AnimatedColorsDemo> createState() => _AnimatedColorsDemoState();
}

class _AnimatedColorsDemoState extends State<AnimatedColorsDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _loadShader();
  }

  Future<void> _loadShader() async {
    final program = await ui.FragmentProgram.fromAsset(
      'assets/shaders/animated_colors.frag',
    );
    setState(() {
      _shader = program.fragmentShader();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _shader == null
            ? const CircularProgressIndicator(color: Colors.white)
            : AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: AnimatedColorsPainter(_shader!, _controller.value),
                    size: Size(
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height,
                    ),
                  );
                },
              ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class AnimatedColorsPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;

  AnimatedColorsPainter(this.shader, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    // Set uniforms
    shader.setFloat(0, size.width); // iResolution.x
    shader.setFloat(1, size.height); // iResolution.y
    shader.setFloat(2, time * 2); // iTime

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

#### Step 6: Run Your App

```bash
flutter run
```

You should see a colorful animated shader effect!

![Animated Colors Effect](animated_colors.gif)

Now that you've successfully created your first shader effect, let's explore the different ways you can use shaders in a Flutter app. The following examples demonstrate various techniques, from using `CustomPainter` for drawing effects from scratch to applying shaders to existing widgets with `ImageFilter`.

For a deeper dive into the technical differences between these approaches and to understand when to use each one, be sure to read our guide on [How Shaders Work](/how-shaders-work/).

Let's look at the examples.

## Example 1: CustomPainter + FragmentShader
**Creates visual effects from scratch**

![Gradient Flow Effect](gradient_flow.gif)

### Dart Code:
```dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class CustomPainterDemo extends StatefulWidget {
  const CustomPainterDemo({super.key});

  @override
  State<CustomPainterDemo> createState() => _CustomPainterDemoState();
}

class _CustomPainterDemoState extends State<CustomPainterDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _loadShader();
  }

  Future<void> _loadShader() async {
    final program = await ui.FragmentProgram.fromAsset(
      'assets/shaders/gradient_flow.frag',
    );
    setState(() {
      _shader = program.fragmentShader();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _shader == null
            ? const CircularProgressIndicator(color: Colors.white)
            : AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ShaderPainter(_shader!, _controller.value),
                    size: Size(
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height,
                    ),
                  );
                },
              ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;

  ShaderPainter(this.shader, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time * 2);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```


## Example 2: flutter_shaders Package
**Simplified shader usage with ShaderBuilder**

![Stripes Pattern Effect](stripes.gif)

First add the dependency:
```yaml
dependencies:
  flutter_shaders: ^0.1.3
```

### Dart Code:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class FlutterShadersDemo extends StatefulWidget {
  const FlutterShadersDemo({super.key});

  @override
  State<FlutterShadersDemo> createState() => _FlutterShadersDemoState();
}

class _FlutterShadersDemoState extends State<FlutterShadersDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ShaderBuilder(assetKey: 'assets/shaders/stripes_pattern.frag', (
        context,
        shader,
        child,
      ) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return AnimatedSampler(
              (image, size, canvas) {
                shader.setFloat(0, size.width);
                shader.setFloat(1, size.height);
                shader.setFloat(2, _controller.value * 4.0);

                final paint = Paint()..shader = shader;
                canvas.drawRect(Offset.zero & size, paint);
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.blue, Colors.green],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Flutter Shaders\nAnimated Demo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```


## Example 3: ImageFilter.shader
**Apply shader effects to any widget** (Requires Impeller)

![Ripple Effect](ripple_effect.gif)

### Dart Code:
```dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ImageFilterDemo extends StatefulWidget {
  const ImageFilterDemo({super.key});

  @override
  State<ImageFilterDemo> createState() => _ImageFilterDemoState();
}

class _ImageFilterDemoState extends State<ImageFilterDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _loadShader();
  }

  Future<void> _loadShader() async {
    final program = await ui.FragmentProgram.fromAsset(
      'assets/shaders/ripple_effect.frag',
    );
    setState(() {
      _shader = program.fragmentShader();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_shader == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          _shader!.setFloat(0, MediaQuery.of(context).size.width);
          _shader!.setFloat(1, MediaQuery.of(context).size.height);
          _shader!.setFloat(2, _controller.value * 2);

          return ImageFiltered(
            imageFilter: ui.ImageFilter.shader(_shader!),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
              child: GridView.builder(
                padding: const EdgeInsets.all(40),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 30,
                  crossAxisSpacing: 30,
                ),
                itemCount: 25,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.flutter_dash,
                      size: 80,
                      color: Colors.blue,
                    ),
                  );
                },
              ),
            );
          },
        ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

## Example 4: BackdropFilter
**Apply shader effects to background content** (Requires Impeller)

![Backdrop Effect](backdrop_effect.gif)

### Dart Code:
```dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class BackdropFilterDemo extends StatefulWidget {
  const BackdropFilterDemo({super.key});

  @override
  State<BackdropFilterDemo> createState() => _BackdropFilterDemoState();
}

class _BackdropFilterDemoState extends State<BackdropFilterDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _loadShader();
  }

  Future<void> _loadShader() async {
    final program = await ui.FragmentProgram.fromAsset(
      'assets/shaders/ripple_effect.frag',
    );
    setState(() {
      _shader = program.fragmentShader();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
              ),
              itemCount: 36,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.flutter_dash,
                    size: 60,
                    color: Colors.blue,
                  ),
                );
              },
            ),
          ),

          if (_shader != null)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    _shader!.setFloat(0, 400);
                    _shader!.setFloat(1, 300);
                    _shader!.setFloat(2, _controller.value * 2);

                    return BackdropFilter(
                      filter: ui.ImageFilter.shader(_shader!),
                      child: Container(
                        width: 400,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Shader Backdrop Effect',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```