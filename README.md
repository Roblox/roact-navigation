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

### As a Rotriever dependency
* Add a \[dependencies\] entry to your rotriever.toml file, ex: `RoactNavigation = "roblox/roact-navigation@0.2.8"`
* Run `rotrieve install`

### For development
* Clone the repository, ex: `git clone https://github.com/Roblox/roact-navigation.git`.
* Sync the required dev dependencies via submodules:  `git submodule update --init --recursive`
* Get [foreman](https://github.com/Roblox/foreman/releases) to install the development tools. Run `foreman install`, which should install `rojo` and `rotriever`. If it's the first time you're using foreman, make sure to add `~/.foreman/bin` to your PATH and setup a [personal access token](https://github.com/Roblox/foreman#authentication) to foreman (needed for rotriever).
* Run `rotrieve install` to sync the runtime dependencies.

## Running the unit tests

### With Lemur (standalone Lua)
* Set up your system with Lua 5.1.
* Install dependencies for [Lemur](https://github.com/LPGhatguy/lemur).
* Follow the development installation instructions.
* Run `lua bin/spec.lua`.

### With roblox-cli
* Build the storybook test place: `rojo build storybook.project.json --output test-place.rbxlx`
* Run roblox-cli `roblox-cli run --load.place test-place.rbxlx --load.asRobloxScript --run scripts/run-tests.lua`

## Running the Storybooks
* Install the [Horsecat](https://github.com/Roblox/horsecat/blob/master/docs/index.md) plugin.
* Build the Rojo storybook project `rojo build storybook.project.json -o roactnavigation.rbxlx`.
* Serve the Rojo project to Roblox Studio `rojo serve storybook.project.json` so it can do dynamic updates when you edit files.
* Launch Roblox Studio and open roactnavigation.rbxlx.
* Go to Game Settings/Options and turn on "Allow HTTP Requests".
* Connect to Rojo server on localhost via Plugins/Connect, usually localhost/34872.
* Open the storybook in ReplicatedStorage/Packages/RoactNavigationStorybook.

## Running the Rhodium tests

### In Studio
* Build the Rhodium project `rojo build rhodium.project.json -o RoactNavigationRhodiumTestRunner.rbxm`.
* Copy the test runner rbxm to your Roblox Studio installation's BuiltInPlugins directory. Make sure the plugin is [signed](https://confluence.rbx.com/pages/viewpage.action?spaceKey=DEVSRVC&title=Signing+built-in+plugins+locally+on+your+development+machine)
* Open any placefile.
* Click the "Run Tests" button that shows up in the left panel.

### With roblox-cli
* Build the Rhodium test place project: `rojo build rhodium-place.project.json --output rhodium-test-place.rbxlx`
* Run roblox-cli: `roblox-cli run --headlessRenderer on --virtualInput on --load.place rhodium-test-place.rbxlx --load.asRobloxScript --run scripts/run-rhodium-tests.lua`

## Building the rbxm library module
* Perform Rust and Rojo setup steps as per "Running the Storybooks"
* Build Rojo project `rojo build -o RoactNavigation.rbxm`.

## Publish Roact-Navigation
1. **git**
	1. Update the CHANGELOG.md to list all the changes since the last tag
	2. Update version number in rotriever.toml
	3. Generate new tag in roact-navigationr repository (pick ONE):

		- Run "rotrieve publish" to automatically generate the tag.

		- *(OR)* Manually create a new annotated tag:
			1. `cd roact-navigation`
			2. `git tag -a v0.x.y ` (Number should match rotriever.toml; use `git tag -l` to see all tags)
			3. Copy-paste the changelog entry into the tag annotation.
			4. `git push origin v0.x.y`

2. **Publish to Roblox internal artifact repository**
	1. go to: https://teamcity.simulpong.com/buildConfiguration/LuaAppsAndTools_CacheRotrieverPackage
	2. Click run.
	3. Put in the RN repository, e.g. `GitHub.com/roblox/roact-navigation`
	4. Put in your new version number, e.g. `0.2.7`. (It will prepend 'v' automatically for the tag.)
	5. Click "Run Build".

## Caveats/Concerns
* Otter version [9ad129e](https://github.com/Roblox/otter/commit/9ad129e70e103d0de71232a0d0e7a1527da7a51a) or later is required to avoid the motor:start() timing bugs.

## License
Roact Navigation is closed source, for the time being. All rights are reserved to Roblox.
