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

Roact Navigation documentation is available internally on Roblox Confluence, here:
https://confluence.rbx.com/display/MOBAPP/Roact+Navigation

## Installation

### Filesystem
* Add this repository as a Git submodule or copy it into your project.
* Sync the required submodules. `git submodule update --init --recursive`
* Set up your project to import the files under the "src" folder.

## Caveats/Concerns
* Roact-Navigation is designed to work with pre-1.0 Roact (no bindings) to preserve maximum compatibility.
* Otter version 9ad129e70e103d0de71232a0d0e7a1527da7a51a or later is required to avoid the motor:start() timing bugs.

## Running the unit tests
* Set up your system with Lua 5.1.
* Install dependencies for [Lemur](https://github.com/LPGhatguy/lemur).
* Run `lua bin/spec.lua`.

## Running the Storybooks
* Install a [Rust](https://www.rust-lang.org) compiler toolchain and runtime.
* Install Rojo `cargo install rojo --version 0.5.0-alpha.12`.
* Build Rojo project `rojo build -o roactnavigation.rbxl`.
* Serve the Rojo project to Roblox Studio `rojo serve` so it can do dynamic updates when you edit files.
* Launch Studio and follow the [Horsecat](https://github.com/Roblox/horsecat/blob/master/docs/index.md) docs to open the storybooks in ReplicatedStorage/RoactNavigation-Storybook.

## License
Roact Navigation is closed source, for the time being. All rights are reserved to Roblox.
