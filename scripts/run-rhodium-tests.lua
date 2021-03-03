local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProcessService = game:GetService("ProcessService")

local Packages = ReplicatedStorage.Packages
local Tests = ReplicatedStorage.Tests

local JestRoblox = require(Packages.Dev.JestRoblox)
local Rhodium = require(Packages.Dev.Rhodium)

local result = JestRoblox.TestBootstrap:run({ Tests }, JestRoblox.Reporters.TextReporterQuiet, {
	noXpcallByDefault = true,
	extraEnvironment = {
		Rhodium = Rhodium,
	}
})

if result.failureCount == 0 then
	ProcessService:ExitAsync(0)
else
	ProcessService:ExitAsync(1)
end
