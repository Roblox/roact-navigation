local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProcessService = game:GetService("ProcessService")

local JestRoblox = require(ReplicatedStorage.Packages.Dev.JestRoblox)

local RoactNavigation = ReplicatedStorage.Packages.RoactNavigation

local result = JestRoblox.TestBootstrap:run({ RoactNavigation }, JestRoblox.Reporters.TextReporterQuiet)

if result.failureCount == 0 then
	ProcessService:ExitAsync(0)
else
	ProcessService:ExitAsync(1)
end
