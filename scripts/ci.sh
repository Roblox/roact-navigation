#!/bin/sh

set -ex

selene src Storybook RhodiumTests

robloxdev-cli run --load.model test-bundle.project.json --run ./scripts/run-tests.lua --fastFlags.overrides EnableLoadModule=true

robloxdev-cli run --load.model test-bundle.project.json --run ./scripts/run-tests.lua --fastFlags.overrides EnableLoadModule=true --lua.globals=__NEW_ROACT__=true

robloxdev-cli run --headlessRenderer on --virtualInput on --load.model test-bundle-rhodium.project.json --load.asRobloxScript --run ./scripts/run-rhodium-tests.lua --fastFlags.overrides EnableLoadModule=true

robloxdev-cli run --headlessRenderer on --virtualInput on --load.model test-bundle-rhodium.project.json --load.asRobloxScript --run ./scripts/run-rhodium-tests.lua --fastFlags.overrides EnableLoadModule=true --lua.globals=__NEW_ROACT__=true
