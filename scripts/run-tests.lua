local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProcessService = game:GetService("ProcessService")

local TestEZ = require(ReplicatedStorage.Packages.Dev.TestEZ)

local RoactNavigation = ReplicatedStorage.Packages.RoactNavigation

local result = TestEZ.TestBootstrap:run({ RoactNavigation }, TestEZ.Reporters.TextReporterQuiet)

if result.failureCount == 0 then
	ProcessService:ExitAsync(0)
else
	ProcessService:ExitAsync(1)
end
