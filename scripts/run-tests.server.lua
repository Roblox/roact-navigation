local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TestEZ = require(ReplicatedStorage.Packages.Dev.TestEZ)

local RoactNavigation = ReplicatedStorage.Packages.RoactNavigation

TestEZ.TestBootstrap:run({ RoactNavigation }, TestEZ.Reporters.TextReporter)