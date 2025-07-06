import 'dart:io';

import 'package:static_shock/static_shock.dart';

Future<void> main(List<String> arguments) async {
  // Configure the static website generator.
  final staticShock = StaticShock()
    // Here, you can directly hook into the StaticShock pipeline. For example,
    // you can copy an "images" directory from the source set to build set:
    ..pick(DirectoryPicker.parse("images"))
    ..pick(ExtensionPicker("mp4"))
    ..pick(ExtensionPicker("png"))
    ..pick(ExtensionPicker("gif"))
    // All 3rd party behavior is added through plugins, even the behavior
    // shipped with Static Shock.
    ..plugin(const MarkdownPlugin())
    ..plugin(const JinjaPlugin())
    ..plugin(const PrettyUrlsPlugin())
    ..plugin(const SassPlugin())
    ..plugin(const TailwindPlugin(
      input: "source/styles/tailwind.css",
      output: "build/styles/tailwind.css",
    ))
    ..plugin(
      GitHubContributorsPlugin(
        authToken: Platform.environment["github_doc_website_token"],
        repositories: {
          GitHubRepository(organization: "flutter-bounty-hunters", name: "flutter_shaders"),
        },
      ),
    );

  // Generate the static website.
  await staticShock.generateSite();
}
