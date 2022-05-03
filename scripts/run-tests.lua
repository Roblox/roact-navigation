local ProcessService = game:GetService("ProcessService")

local root = script.Parent.TestBundle
local Packages = root.Packages

local JestGlobals = require(Packages.Dev.JestGlobals)

local RoactNavigation = Packages.RoactNavigation

local result = JestGlobals.TestEZ.TestBootstrap:run(
	{ RoactNavigation },
	JestGlobals.TestEZ.Reporters.TextReporterQuiet
)

if result.failureCount == 0 and #result.errors == 0 then
	ProcessService:ExitAsync(0)
else
	ProcessService:ExitAsync(1)
end
