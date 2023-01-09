#!/bin/sh

set -ex

roblox-cli analyze test-bundle.project.json
selene src Storybook RhodiumTests
stylua -c src Storybook RhodiumTests

robloxdev-cli run --load.model test-bundle.project.json --run ./scripts/run-tests.lua --lua.globals=__ROACT_17_MOCK_SCHEDULER__=true

robloxdev-cli run --load.model test-bundle.project.json --run ./scripts/run-tests.lua --lua.globals=__ROACT_17_MOCK_SCHEDULER__=true --lua.globals=__DEV__=true

robloxdev-cli run --headlessRenderer on --virtualInput on --load.model test-bundle-rhodium.project.json --load.asRobloxScript --run ./scripts/run-rhodium-tests.lua --lua.globals=__ROACT_17_MOCK_SCHEDULER__=true

robloxdev-cli run --headlessRenderer on --virtualInput on --load.model test-bundle-rhodium.project.json --load.asRobloxScript --run ./scripts/run-rhodium-tests.lua --lua.globals=__ROACT_17_MOCK_SCHEDULER__=true --lua.globals=__DEV__=true
