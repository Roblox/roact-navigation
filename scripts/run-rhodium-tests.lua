local ProcessService = game:GetService("ProcessService")

local root = script.Parent.TestBundleRhodium
local Packages = root.Packages
local Tests = root.Tests

local JestGlobals = require(Packages.Dev.JestGlobals)
local Rhodium = require(Packages.Dev.Rhodium)

local result = JestGlobals.TestEZ.TestBootstrap:run(
	{ Tests },
	JestGlobals.TestEZ.Reporters.TextReporterQuiet,
	{
		noXpcallByDefault = true,
		extraEnvironment = {
			Rhodium = Rhodium,
		}
	}
)

if result.failureCount == 0 and #result.errors == 0 then
	ProcessService:ExitAsync(0)
else
	ProcessService:ExitAsync(1)
end
