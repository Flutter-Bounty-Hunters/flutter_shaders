# Contributing
Do you have a shader that you'd like to add to the website? Follow these instructions to contribute your shader.

## Shader Purpose Check
This website exists to share shaders among Flutter developers, for the purpose of using those shaders
in applications.

Please don't submit any shaders that aren't directly useful for Flutter application development
purposes. If you'd like to share artistic shaders, or game shaders, please try http://shadertoy.com

## Intellectual Property Check
By contributing a shader to this website, you're applying this repository's license to the shader
code.

Did you write the shader code yourself? If so, make sure you're OK with applying the terms in [LICENSE](LICENSE).

Did someone else write some or all of the shader code? Check the license on the shader code to ensure
that you're allowed to post that code under the terms of our [LICENSE](LICENSE).

## What You'll Need
Here's what you'll need when contributing a shader.

 * A short, descriptive shader name.
 * A single sentence description of the shader.
 * A square marketing screenshot of the shader (see other shaders for dimensions).
 * A rectangular video showing the shader in action (see other shaders for dimensions).
 * The code for the shader.

## Contributing Your Shader
Once you've assembled what you'll need, clone this repository and do the following:

1. Create a new directory for your shader under `/source/shaders`, e.g., `/source/shaders/ripple`.
2. Place your screenshot image in that directory, e.g., `/source/shaders/ripple/ripple.png`.
3. Place your video in that directory, e.g., `/source/shaders/ripple/ripple.mp4`.
4. Create a Markdown file to hold your info and code. Name it `index.md`, e.g., `/source/shaders/ripple/index.md`.

Inside of `index.md`, begin with a Frontmatter declaration that includes your shader info.

    ---
    description: [Insert a metadata description that will be served to X/Facebook/Google - this can be the same as the shader description]
    shader:
     title: [Insert shader name]
     description: [Insert shader description]
     screenshot: [Insert screenshot file name, e.g., "ripple.png"]
     video: [Insert video file name, e.g., "ripple.mp4"]
    # For the moment we need to record the path to this directory until Static Shock provides this
    directory: [Insert the path to this directory, e.g., "shaders/ripple/"]
    ---

Below the Frontmatter data, paste your shader code:

    ---
    description: ...
    ...
    ---
    
    ```glsl
    [INSERT CODE HERE]
    ```

**The easiest way to write your `index.md` is to copy an existing file and adjust its values.**

Create a new Git branch with whatever name you'd like. Then, commit your changes with a message like
the following:

    [New Shader] - [INSERT SHADER NAME]

For example:

    [New Shader] - Water Ripple

Open a Pull Request to merge your shader into the website. We'll review your shader. If everything
looks good then we'll merge your PR, and the website will automatically rebuild and re-deploy with
your new shader.

Thanks for contributing!
