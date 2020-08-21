--[[
	Usage:
		lua bin/spec.lua

	Loads our project and all of its dependencies using Lemur, then runs tests
	using TestEZ.
]]

-- If you add any non-Rotriever dependencies, add them to this table so they'll be loaded!
local LOAD_MODULES = {
	{"src", "roact-navigation"},
}

-- This makes sure we can load libraries that depend on init.lua, like Lemur.
package.path = package.path .. ";?/init.lua"

-- If this fails, make sure you've cloned all Git submodules of this repo!
local lemur = require("modules.lemur")

-- A Habitat is an emulated DataModel from Lemur
local habitat = lemur.Habitat.new()

-- Load Rotriever packages
local Packages = habitat:loadFromFs("Packages")
Packages.Name = "Packages"
Packages.Parent = habitat.game:GetService("ReplicatedStorage")

for _, module in ipairs(LOAD_MODULES) do
	local container = habitat:loadFromFs(module[1])
	container.Name = module[2]
	container.Parent = Packages
end

-- Load RoactNavigation source into Packages folder so it's next to Roact as expected
local RoactNavigation = habitat:loadFromFs("src")
RoactNavigation.Name = "roact-navigation"
RoactNavigation.Parent = Packages

local TestEZ = habitat:require(Packages.Dev.TestEZ)

-- Run all tests, collect results, and report to stdout.
local results = TestEZ.TestBootstrap:run(
	{ Packages["roact-navigation"] },
	TestEZ.Reporters.TextReporterQuiet
)

if results.failureCount > 0 then
	-- If something went wrong, explicitly terminate with a failure error code
	-- so that services like Travis-CI will know.
	os.exit(1)
end
