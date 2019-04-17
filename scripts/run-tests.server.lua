local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TestEZ = require(ReplicatedStorage.Modules.TestEZ)

local RoactNavigation = ReplicatedStorage.Modules.RoactNavigation

TestEZ.TestBootstrap:run({ RoactNavigation }, TestEZ.Reporters.TextReporter)