local bundle = script.Parent.TestBundle
local Packages = bundle.Packages
local JestGlobals = require(Packages.Dev.JestGlobals)
local Tests = bundle.Tests

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

	JestGlobals.TestEZ.TestBootstrap:run({Tests}, JestGlobals.TestEZ.Reporters.TextReporter, {
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
