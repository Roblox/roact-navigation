#!/bin/sh

set -ex

roblox-cli analyze test-bundle.project.json
selene src Storybook RhodiumTests

robloxdev-cli run --load.model test-bundle.project.json --run ./scripts/run-tests.lua --fastFlags.overrides EnableLoadModule=true

robloxdev-cli run --load.model test-bundle.project.json --run ./scripts/run-tests.lua --fastFlags.overrides EnableLoadModule=true --lua.globals=__NEW_ROACT__=true --lua.globals=__ROACT_17_COMPAT_LEGACY_ROOT__=true

robloxdev-cli run --headlessRenderer on --virtualInput on --load.model test-bundle-rhodium.project.json --load.asRobloxScript --run ./scripts/run-rhodium-tests.lua --fastFlags.overrides EnableLoadModule=true

robloxdev-cli run --headlessRenderer on --virtualInput on --load.model test-bundle-rhodium.project.json --load.asRobloxScript --run ./scripts/run-rhodium-tests.lua --fastFlags.overrides EnableLoadModule=true --lua.globals=__NEW_ROACT__=true --lua.globals=__ROACT_17_COMPAT_LEGACY_ROOT__=true
