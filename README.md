<h1 align="center">Roact Navigation</h1>
<div align="center">

![CI](https://github.com/Roblox/roact-navigation-internal/.github/workflows/ci.yml/badge.svg)

<a href="https://coveralls.io/github/Roblox/roact-navigation-internal?branch=master">
<img src="https://coveralls.io/repos/github/Roblox/roact-navigation-internal/badge.svg?branch=master" alt="Coveralls Coverage" />
</a>

<a href="https://reactnavigation.org/docs/4.x/getting-started">
<img src="https://img.shields.io/badge/docs-website-green.svg" alt="Documentation" />
</a>

<a href="https://roblox.slack.com/archives/C0109R8UFK2">
<img src="https://img.shields.io/badge/slack-%23roact--navigation-ff68b4.svg" alt="Slack channel" />
</a>

</div>

Roact Navigation provides a declarative navigation system for App UI, built on top of Roact. Slack channel [#roact-navigation]().

## Install with Rotriever

### Adding Roact Navigation to your dependencies
In your [rotriever.toml](https://pages.github.rbx.com/pdoyle/rotriever-docs/getting-started/) file from your project, add an entry in the `dependencies` section:

```toml
[package]
name = "roblox/cool-plugin-that-uses-roact-navigation"
version = "0.4.1"
author = "Roblox"
content_root = "src"

[dependencies]
# adding this line will make your project depend on version 0.5.10
RoactNavigation = "Roblox/roact-navigation-internal@0.5.10"
# ... the rest of your dependencies ...

[dev_dependencies]
# ...
```

To view a list of available version, visit the [releases](https://github.com/Roblox/roact-navigation-internal/releases) page.

### Get the source
Now that Roact Navigation is added to your rotriever dependencies, simply run the following command to download the package:

```bash
rotrieve install
```

## Contributing

Read the [contribute guide](CONTRIBUTING.md) to get started.

## Documentation

Since Roact Navigation is based on React Navigation version 4, a lot of the [documentation](https://reactnavigation.org/docs/4.x/getting-started) from the original JavaScript package can be used as a reference. There is also a [deviation document](docs/deviations.md) that highlights the main differences between the Lua version and the JavaScript version

As part of the Lua tech talks, a presentation of Roact Navigation was recorded and available for employees. Visit the [Lua tech talk schedule](https://confluence.rbx.com/display/LG/Lua+Tech+Talk+Schedule) and look for the presentation on April 12th (2021).

## Caveats/Concerns
* Otter version [9ad129e](https://github.com/Roblox/otter/commit/9ad129e70e103d0de71232a0d0e7a1527da7a51a) or later is required to avoid the motor:start() timing bugs.

## License
Roact Navigation mostly kept the same license (MIT) as the original JavaScript version.
