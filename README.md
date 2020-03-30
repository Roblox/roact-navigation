<h1 align="center">Roact Navigation</h1>
<div align="center">
<a href="https://travis-ci.org/Roblox/roact-navigation">
<img src="https://api.travis-ci.org/Roblox/roact-navigation.svg?branch=master" alt="Travis-CI Build Status" />
</a>
<a href="https://coveralls.io/github/Roblox/roact-navigation?branch=master">
<img src="https://coveralls.io/repos/github/Roblox/roact-navigation/badge.svg?branch=master" alt="Coveralls Coverage" />
</a>
<a href="https://roblox.github.io/roact-navigation">
<img src="https://img.shields.io/badge/docs-website-green.svg" alt="Documentation" />
</a>
</div>

<div align="center">
Roact Navigation provides a declarative navigation system for App UI, built on top of Roact.
</div>

<div>&nbsp;</div>

## Documentation

We are in the process of migrating documentation to GitHub Wiki for more convenient access.

Until the migration is complete, you can view the original documentation on Roblox's internal Confluence, here:
https://confluence.rbx.com/display/MOBAPP/Roact+Navigation

## Installation

### As a dependency
* Add a \[dependencies\] entry to your rotriever.toml file, ex:
`RoactNavigation = "roblox/roact-navigation@0.2"
* Run `rotrieve install`

### For development
* Clone the repository, ex: `git clone https://github.com/Roblox/roact-navigation.git`.
* Sync the required dev dependencies via submodules:  `git submodule update --init --recursive`
* Run `rotrieve install` to sync the runtime dependencies.

## Running the unit tests
* Set up your system with Lua 5.1.
* Install dependencies for [Lemur](https://github.com/LPGhatguy/lemur).
* Follow the development installation instructions.
* Run `lua bin/spec.lua`.

## Running the Storybooks
* Install a [Rust](https://www.rust-lang.org) compiler toolchain and runtime.
* Install Rojo `cargo install rojo --version 0.5.3`.
* Install the [Horsecat](https://github.com/Roblox/horsecat/blob/master/docs/index.md) plugin.
* Build Rojo storybook project `rojo build -o roactnavigation.rbxlx storybook.project.json`.
* Serve the Rojo project to Roblox Studio `rojo serve storybook.project.json` so it can do dynamic updates when you edit files.
* Launch Roblox Studio and open roactnavigation.rbxlx.
* Go to Game Settings/Options and turn on "Allow HTTP Requests".
* Connect to Rojo server on localhost via Plugins/Connect, usually localhost/34872.
* Open the storybook in ReplicatedStorage/Packages/RoactNavigationStorybook.

## Running the Rhodium tests
* Perform Rust and Rojo setup steps as per "Running the Storybooks"
* Build the Rhodium project `rojo build -o RoactNavigationRhodiumTestRunner.rbxm rhodium.project.json`.
* Copy the test runner rbxm to your Roblox Studio installation's BuiltInPlugins directory.
* Open any placefile (the storybook one is probably best).
* Start game, and then click the "Run Tests" button that shows up in the left panel.

## Building the rbxm library module
* Perform Rust and Rojo setup steps as per "Running the Storybooks"
* Build Rojo project `rojo build -o RoactNavigation.rbxm`.

## Propagating changes from git to Perforce
Documented in [Publish Roact-Navigation - From Git to Perforce](docs/PublishRoactNavigationFromGitToPerforce.md)

## Caveats/Concerns
* Roact-Navigation is designed to work with pre-1.0 Roact (no bindings) to preserve maximum compatibility.
* Otter version [9ad129e](https://github.com/Roblox/otter/commit/9ad129e70e103d0de71232a0d0e7a1527da7a51a) or later is required to avoid the motor:start() timing bugs.

## License
Roact Navigation is closed source, for the time being. All rights are reserved to Roblox.
