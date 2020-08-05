local Packages = script.Parent.Packages
local TestEZ = require(Packages.Dev.TestEZ)
local Tests = script.Parent.Tests

local dockWidgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Left,
	true, true, 100, 100, 100, 100
)

local dockWidget = plugin:CreateDockWidgetPluginGui("RoactNavigationRhodiumRunner", dockWidgetInfo)
dockWidget.Title = "Roact Navigation Rhodium Runner"
dockWidget.Name = "Roact Navigation Rhodium Runner"

local runButton = Instance.new("TextButton")
runButton.Size = UDim2.new(1, 0, 1, 0)
runButton.Position = UDim2.new(0, 0, 0, 0)
runButton.TextSize = 32
runButton.Text = "Run Test"
runButton.Parent = dockWidget

local function runRhodiumTests()
	local Rhodium = require(Packages.Dev.Rhodium)

	TestEZ.TestBootstrap:run({Tests}, TestEZ.Reporters.TextReporter, {
		noXpcallByDefault = true,
		extraEnvironment = {
			Rhodium = Rhodium,
		}
	})
end

local isRunning = false
runButton.Activated:connect(function()
	if isRunning then return end

	isRunning = true
	runButton.Text = "Test running..."
	runRhodiumTests()
	isRunning = false
	runButton.Text = "Run Test"
end)
