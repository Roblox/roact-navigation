#!/bin/sh

set -ex

selene src Storybook RhodiumTests

roblox-cli run --load.model test-bundle.project.json --run ./scripts/run-tests.lua --fastFlags.overrides "UseDateTimeType3=true" --fastFlags.overrides EnableLoadModule=true

roblox-cli run --load.model test-bundle.project.json --run ./scripts/run-tests.lua --fastFlags.overrides "UseDateTimeType3=true" --fastFlags.overrides EnableLoadModule=true --lua.globals=__NEW_ROACT__=true

robloxdev-cli run --headlessRenderer on --virtualInput on --load.model test-bundle-rhodium.project.json --load.asRobloxScript --run ./scripts/run-rhodium-tests.lua --fastFlags.overrides UseDateTimeType3=true --fastFlags.overrides EnableLoadModule=true

roblox-cli run --headlessRenderer on --virtualInput on --load.model test-bundle-rhodium.project.json --load.asRobloxScript --run ./scripts/run-rhodium-tests.lua --fastFlags.overrides UseDateTimeType3=true --fastFlags.overrides EnableLoadModule=true --lua.globals=__NEW_ROACT__=true