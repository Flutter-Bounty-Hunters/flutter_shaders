---
title: How Shaders Work in Flutter
description: Understand the core concepts of fragment shaders, how they integrate with Flutter, and the different rendering approaches available.
layout: layouts/content_page.jinja
directory: how-shaders-work/
---

# How Shaders Work in Flutter
This guide explores the fundamental concepts behind shaders in Flutter, from the basics of fragment shaders to the different ways you can use them in your applications.

## What Are Fragment Shaders?
Fragment shaders are small GPU programs that determine the color of each pixel on the screen. Think of them as functions that run in parallel for every pixel, where:

- **Input**: The pixel's position (coordinates) and custom parameters called uniforms
- **Output**: A single color value for that pixel

**NOTE**: Shaders run on the GPU, making them incredibly fast. Fragment shaders are typically the final step in the graphics pipeline, which is why they're so efficient for real-time effects.

## Flutter + Fragment Shaders
Flutter is hardware-accelerated, meaning it leverages GPU shaders for rendering. Every widget you see - from a simple `Container` to complex blur effects - is ultimately rendered using optimized shaders. This is what makes Flutter so smooth and performant across platforms.

## Types of Shader Usage in Flutter
There are three main ways to use custom shaders in Flutter:

![Types of Shader Usage in Flutter](usage_examples.png)


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

## Different Approaches to Using Shaders in Flutter

#### 1. CustomPainter + FragmentShader
- **Use Case**: Paint from scratch using the GPU
- **Pros**: Direct access to raw shader API
- **Cons**: More complex setup and boilerplate code

#### 2. ImageFiltered + ImageFilter.shader
- **Use Case**: Apply shader effects to child widgets
- **Pros**: Easy to apply shader effects to any widget
- **Cons**: Requires Impeller renderer; cannot control the first two uniforms (vec2 for texture size and sampler2D) as they are set by the Flutter engine

#### 3. BackdropFilter + ImageFilter.shader
- **Use Case**: Apply shader effects to background content
- **Pros**: Easy backdrop shader effects
- **Cons**: Requires Impeller renderer;cannot control the first two uniforms (vec2 for texture size and sampler2D) as they are set by the Flutter engine

#### 4. flutter_shaders Package
- **Use Case**: Simplified shader usage - easily transform any widget into a shader-compatible image
- **Pros**: Less boilerplate code; full control over all unifroms.
- **Cons**: Requires an external dependency; Can't integrate with BackdropFilter widget


### Key Differences: ImageFilter.shader vs. flutter_shaders

**ImageFilter.shader** (Native Flutter API):

*   **Integration**: Built directly into the Flutter framework (`dart:ui`).
*   **Rendering Backend**: **Requires the Impeller rendering engine.** It will not work with other backends.
*   **BackdropFilter**: **Supports `BackdropFilter`**, allowing you to apply shader effects to the content behind a widget.
*   **API Flexibility**: Operates on a "convention over configuration" model. It simplifies the process by automatically providing and managing core uniforms (like the input texture), but this reduces flexibility as you have less control over the shader's direct inputs.
*   **Dependencies**: None, as it's part of the Flutter SDK.

**flutter_shaders** (Third-party Package):

*   **Integration**: A community-created package that needs to be added as a dependency.
*   **Rendering Backend**: **Backend-agnostic**, making it compatible with various rendering backends, not just Impeller.
*   **BackdropFilter**: **Does not directly support `BackdropFilter`**. Its effects are generally limited to the widgets it's applied to.
*   **API Flexibility**: Provides more direct control over the `FragmentShader` object. You have full responsibility for declaring and managing all uniforms, which offers maximum flexibility and power at the cost of potentially more boilerplate code.
*   **Dependencies**: Requires adding the `flutter_shaders` package to your `pubspec.yaml`.

### Rendering Pipeline Performance Impact
A critical difference between these approaches lies in **when and how many times rendering occurs** during the Flutter frame lifecycle:

**ImageFilter.shader** (Native Flutter API):
- Starts during the **build phase** and integrates directly with Flutter's compositing layer
- Processes in **single-pass rendering** within the normal pipeline
- **Does not trigger additional raster operations** beyond the standard frame rendering

You'll notice in the timeline that this process doesn't trigger any additional raster operations beyond what's standard for a frame (compared to the below example).

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
    *   Complex effects requiring fine-grained control over all shader uniforms (for example size unifrom).

## Impeller Status by Platform
**ImageFilter.shader** requires Impeller. Check platform availability:

- **iOS**: Impeller default (Flutter 3.29+)
- **Android**: Impeller default (API 29+), falls back to OpenGL on older versions
- **macOS**: Impeller behind flag
- **Windows/Linux**: Impeller experimental
- **Web**: Uses Skia (no Impeller yet)

For detailed status across Flutter versions, see the [official Flutter team spreadsheet](https://docs.google.com/spreadsheets/d/1AebMvprRkxP-D6ndx920lbvDBbhg-sNNRJ64XY2P2t0/edit?gid=0#gid=0).

