---
title: Getting Started with Flutter Shaders
description: Learn how to create stunning visual effects and performant graphics directly in your Flutter applications with this comprehensive guide.
---

# Getting Started with Flutter Shaders

Shaders in Flutter allow you to create stunning visual effects and performant graphics directly in your Flutter applications. This guide will take you from basic concepts to implementing real shader effects in your apps.

## What Are Fragment Shaders?

Fragment shaders are small GPU programs that determine the color of each pixel on the screen. Think of them as functions that run in parallel for every pixel, where:

- **Input**: The pixel's position (coordinates) and custom parameters called uniforms
- **Output**: A single color value for that pixel

**NOTE**: Shaders run on the GPU, making them incredibly fast. Fragment shaders are typically the final step in the graphics pipeline, which is why they're so efficient for real-time effects.

## Flutter + Fragment Shaders

Flutter is hardware-accelerated, meaning it leverages GPU shaders for rendering. Every widget you see - from a simple `Container` to complex blur effects - is ultimately rendered using optimized shaders. This is what makes Flutter so smooth and performant across platforms.

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
      home: const ShaderDemo(),
    );
  }
}

class ShaderDemo extends StatefulWidget {
  const ShaderDemo({super.key});

  @override
  State<ShaderDemo> createState() => _ShaderDemoState();
}

class _ShaderDemoState extends State<ShaderDemo> 
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
        'assets/shaders/animated_colors.frag');
    setState(() {
      _shader = program.fragmentShader();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Shader Demo'),
      ),
      body: Center(
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: _shader == null
              ? const Center(child: CircularProgressIndicator())
              : AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ShaderPainter(_shader!, _controller.value),
                      size: const Size(300, 300),
                    );
                  },
                ),
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
    // Set uniforms
    shader.setFloat(0, size.width);  // iResolution.x
    shader.setFloat(1, size.height); // iResolution.y
    shader.setFloat(2, time * 2);    // iTime

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

## Different Approaches to Using Shaders in Flutter

### Comparison Table

| Approach | Use Case | Pros | Cons | 
|----------|----------|------|------|
| CustomPainter + FragmentShader | Paint  from scratch using the GPU | Raw API | More complex setup | 
| ImageFilter.shader | Apply shaders to widgets | Easy shader effects child widget | Requires Impeller | 
| BackdropFilter + ImageFilter.shader | Shader effects on background | Easy backdrop shader effects | Requires Impeller | 
| flutter_shaders package | Simplified shader usage - easily tranform any widget into a shader compatible image | Cleaner API, less boilerplate | Extra dependency | 

### Method 1: Using flutter_shaders Package (Recommended)

For easier shader management, you can use the flutter_shaders package:

#### Add Dependency

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_shaders: 
```

#### Simplified Code


```dart
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class ShaderDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShaderBuilder(
      assetKey: 'assets/shaders/animated_colors.frag',
      (context, shader, child) {
        return AnimatedSampler(
          (image, size, canvas) {
            shader.setFloat(0, size.width);
            shader.setFloat(1, size.height);
            shader.setFloat(2, DateTime.now().millisecondsSinceEpoch / 500.0);
            
            final paint = Paint()..shader = shader;
            canvas.drawRect(Offset.zero & size, paint);
          },
          child: Container(
            width: 300,
            height: 300,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }
}
```

### Method 2: Using ImageFilter.shader with ImageFiltered

Apply custom shaders to any widget using ImageFilter.shader. **Note**: This requires Impeller renderer.

```dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ImageFilterShaderDemo extends StatefulWidget {
  @override
  State<ImageFilterShaderDemo> createState() => _ImageFilterShaderDemoState();
}

class _ImageFilterShaderDemoState extends State<ImageFilterShaderDemo>
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
        'assets/shaders/animated_colors.frag');
    setState(() {
      _shader = program.fragmentShader();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_shader == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Update shader uniforms
        _shader!.setFloat(0, 300); // width
        _shader!.setFloat(1, 300); // height  
        _shader!.setFloat(2, _controller.value * 2); // time

        return ImageFiltered(
          imageFilter: ui.ImageFilter.shader(_shader!),
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: const Center(
              child: Text(
                'Shader Effect\nApplied to Widget',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```


### Method 3: Using BackdropFilter with ImageFilter.shader

Apply custom shader effects to background content. **Note**: This also requires Impeller renderer.

```dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class BackdropShaderDemo extends StatefulWidget {
  @override
  State<BackdropShaderDemo> createState() => _BackdropShaderDemoState();
}

class _BackdropShaderDemoState extends State<BackdropShaderDemo>
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
        'assets/shaders/animated_colors.frag');
    setState(() {
      _shader = program.fragmentShader();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background content
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.blue, Colors.green],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Text(
              'Background Content',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        // Shader backdrop effect
        if (_shader != null)
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // Update shader uniforms
                  _shader!.setFloat(0, 300); // width
                  _shader!.setFloat(1, 200); // height
                  _shader!.setFloat(2, _controller.value * 2); // time

                  return BackdropFilter(
                    filter: ui.ImageFilter.shader(_shader!),
                    child: Container(
                      width: 300,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Shader Backdrop Effect',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
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
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```


## Understanding Shader Uniforms

Uniforms are parameters you can pass from Dart to your shader:

```glsl
uniform vec2 iResolution;     // Screen size
uniform vec2 iMouse;          // Mouse/touch position  
uniform float iTime;          // Animation time
uniform sampler2D iChannel0;  // Texture input
```

Set them in Dart:

```dart
shader.setFloat(0, value);           // Single float
shader.setFloat(1, x); shader.setFloat(2, y); // Vec2
shader.setImageSampler(0, image);    // Texture
```

## Integrating Shaders from FlutterShaders.com

To use a shader from this website:

1. **Copy the shader code** from the shader page
2. **Save it** as a `.frag` file in `assets/shaders/`
3. **Add it to your pubspec.yaml** under `flutter: shaders:`
4. **Identify the uniforms** the shader expects
5. **Create a CustomPainter** similar to the example above
6. **Set the required uniforms** in the `paint` method

### Example: Water Ripple Effect

```dart
class RipplePainter extends CustomPainter {
  final ui.FragmentShader shader;
  final Offset touchPosition;
  final double time;
  final ui.Image? backgroundImage;

  RipplePainter(
      this.shader, this.touchPosition, this.time, this.backgroundImage);

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, touchPosition.dx);
    shader.setFloat(3, touchPosition.dy);
    shader.setFloat(4, time);

    if (backgroundImage != null) {
      shader.setImageSampler(0, backgroundImage!);
    } else {
      // Create a simple gradient fallback
      final gradient = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, size.height),
        [Colors.blue, Colors.purple],
      );
      final paint = Paint()..shader = gradient;
      canvas.drawRect(Offset.zero & size, paint);
      return;
    }

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}