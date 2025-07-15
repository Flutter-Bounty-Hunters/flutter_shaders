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

## What Are Fragment Shaders?
Fragment shaders are small GPU programs that determine the color of each pixel on the screen. Think 
of them as functions that run in parallel for every pixel, where:

- **Input**: The pixel's position (coordinates) and custom parameters called uniforms
- **Output**: A single color value for that pixel

**NOTE**: Shaders run on the GPU, making them incredibly fast. Fragment shaders are typically the 
final step in the graphics pipeline, which is why they're so efficient for real-time effects.

## Flutter + Fragment Shaders
Flutter is hardware-accelerated, meaning it leverages GPU shaders for rendering. Every widget you 
see - from a simple `Container` to complex blur effects - is ultimately rendered using optimized 
shaders. This is what makes Flutter so smooth and performant across platforms.

## Types of Shader Usage in Flutter
There are three main ways to use custom shaders in Flutter:

### 1. Paint from Scratch
Create visual effects directly without any underlying content:
- Custom graphics and animations
- Procedural patterns and textures
- Mathematical visualizations

### 2. Modify Widget Content
Transform the appearance of existing widgets:
- Apply filters and effects to images
- Distort or animate widget content
- Create transitions between states

### 3. Backdrop Effects
Modify content behind widgets:
- Blur backgrounds
- Create glass-like effects
- Background distortions


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

## Different Approaches to Using Shaders in Flutter

### Available Shader Approaches

#### 1. CustomPainter + FragmentShader
- **Use Case**: Paint from scratch using the GPU
- **Pros**: Direct access to raw shader API
- **Cons**: More complex setup and boilerplate code

#### 2. ImageFiltered + ImageFilter.shader
- **Use Case**: Apply shader effects to child widgets
- **Pros**: Easy to apply shader effects to any widget
- **Cons**: Requires Impeller renderer; cannot control the first two uniforms (vec2 for texture 
size and sampler2D) as they are set by the Flutter engine

#### 3. BackdropFilter + ImageFilter.shader
- **Use Case**: Apply shader effects to background content
- **Pros**: Easy backdrop shader effects
- **Cons**: Requires Impeller renderer;cannot control the first two uniforms (vec2 for texture 
size and sampler2D) as they are set by the Flutter engine

#### 4. flutter_shaders Package
- **Use Case**: Simplified shader usage - easily transform any widget into a shader-compatible image
- **Pros**: Less boilerplate code; full control over all unifroms.
- **Cons**: Requires an external dependency; Can't integrate with BackdropFilter widget


### Key Differences: ImageFilter.shader vs. flutter_shaders

**ImageFilter.shader** (Native Flutter API):

*   **Integration**: Built directly into the Flutter framework (`dart:ui`).
*   **Rendering Backend**: **Requires the Impeller rendering engine.** It will not work with other 
backends.
*   **BackdropFilter**: **Supports `BackdropFilter`**, allowing you to apply shader effects to the 
content behind a widget.
*   **API Flexibility**: Operates on a "convention over configuration" model. It simplifies the 
process by automatically providing and managing core uniforms (like the input texture), but this 
reduces flexibility as you have less control over the shader's direct inputs.
*   **Dependencies**: None, as it's part of the Flutter SDK.

**flutter_shaders** (Third-party Package):

*   **Integration**: A community-created package that needs to be added as a dependency.
*   **Rendering Backend**: **Backend-agnostic**, making it compatible with various rendering 
backends, not just Impeller.
*   **BackdropFilter**: **Does not directly support `BackdropFilter`**. Its effects are generally 
limited to the widgets it's applied to.
*   **API Flexibility**: Provides more direct control over the `FragmentShader` object. You have 
full responsibility for declaring and managing all uniforms, which offers maximum flexibility and
power at the cost of potentially more boilerplate code.
*   **Dependencies**: Requires adding the `flutter_shaders` package to your `pubspec.yaml`.

### Rendering Pipeline Performance Impact
A critical difference between these approaches lies in **when and how many times rendering occurs** 
during the Flutter frame lifecycle:

**ImageFilter.shader** (Native Flutter API):
- Starts during the **build phase** and integrates directly with Flutter's compositing layer
- Processes in **single-pass rendering** within the normal pipeline
- **Does not trigger additional raster operations** beyond the standard frame rendering

You'll notice in the timeline that this process doesn't trigger any additional raster operations 
beyond what's standard for a frame (compared to the below example).

![ImageFilter starts during build phase](using_image_filter_starts_during_build_phase.png)

High-level view of the frame lifecycle:

![ImageFilter does not trigger raster operation](using_image_filter_starts_during_build_phase_and_does_not_trigger_raster_operation.png)

**flutter_shaders** (Third-party Package):
- Starts during the **compositing phase** using `AnimatedSampler` to capture widget subtrees
- Requires **2 raster frames per UI frame** due to texture capture overhead via `toImageSync()`
- **Triggers additional raster operations** for texture creation and shader application

The timeline shows this extra raster work initiated by the package.

![flutter_shaders starts during compositing phase](using_flutter_shaders_starts_during_compositing_phase.png)

High-level view of the frame lifecycle:

![flutter_shaders triggers raster operation](using_flutter_shaders_starts_during_compositing_phase_and_does_trigger_raster_operation.png)

### When to use which?
*   Use **ImageFilter.shader** for:
    *   Applying shader effects as a BackdropFilter.
    *   Projects where you can rely on the Impeller rendering engine.
    *   Avoiding third-party dependencies.
    *   Optimal performance with single-pass rendering.
*   Use the **flutter_shaders** package for:
    *   Broader compatibility across different Flutter rendering backends (Skia and Impeller).
    *   Complex effects requiring fine-grained control over all shader uniforms (for example size 
unifrom).

## Impeller Status by Platform
**ImageFilter.shader** requires Impeller. Check platform availability:

- **iOS**: Impeller default (Flutter 3.29+)
- **Android**: Impeller default (API 29+), falls back to OpenGL on older versions
- **macOS**: Impeller behind flag
- **Windows/Linux**: Impeller experimental
- **Web**: Uses Skia (no Impeller yet)

For detailed status across Flutter versions, see the [official Flutter team spreadsheet](https://docs.google.com/spreadsheets/d/1AebMvprRkxP-D6ndx920lbvDBbhg-sNNRJ64XY2P2t0/edit?gid=0#gid=0).


## Example 1: CustomPainter + FragmentShader
**Creates visual effects from scratch using the GPU**

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
**Simplified shader usage with automatic texture management**

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
