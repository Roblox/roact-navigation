local Roact = require(script.Parent.Parent.Parent.Roact)
local RoactNavigation = require(script.Parent.Parent.Parent.RoactNavigation)

--[[
	This story demonstrates how to build a component where more than one navigator
	is parented to it. (Note that this means actions from inside those navigators
	cannot reach other parts of the app because there's no way to hook up more than
	one router as pass-through)!

	AppMainScreen (Component):
		AppContainer:
			StackOne (Component) = StackNavigator
				OneA
				OneB
		AppContainer:
			StackTwo (Component) = StackNavigator
				TwoA
				TwoB
]]
return function(target)
	local function RootComponent(_props)
		local stackOneNavigator = RoactNavigation.createRobloxStackNavigator({
			{
				OneA = function(aProps)
					return Roact.createElement("TextLabel", {
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundColor3 = Color3.new(1, 0, 0),
						Text = "Page OneA",
					}, {
						detailButton = Roact.createElement("TextButton", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.new(0.5, 0, 0.5, 30),
							Size = UDim2.new(0.5, 0, 0, 30),
							BackgroundColor3 = Color3.new(1, 1, 1),
							TextColor3 = Color3.new(0, 0, 0),
							TextSize = 18,
							Text = "Go to Detail B",
							[Roact.Event.Activated] = function()
								aProps.navigation.navigate("OneB")
							end,
						}),
					})
				end,
			},
			{
				OneB = function(bProps)
					return Roact.createElement("TextLabel", {
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundColor3 = Color3.new(0, 1, 0),
						Text = "Page OneB",
					}, {
						backButton = Roact.createElement("TextButton", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.new(1, 1, 1),
							Size = UDim2.new(0, 160, 0, 30),
							Position = UDim2.new(0.5, 0, 0.5, 30),
							Text = "Go Back",
							TextColor3 = Color3.new(0, 0, 0),
							TextSize = 18,
							[Roact.Event.Activated] = function()
								bProps.navigation.goBack()
							end,
						}),
					})
				end,
			},
		})

		local stackTwoNavigator = RoactNavigation.createRobloxStackNavigator({
			{
				TwoA = function(aProps)
					return Roact.createElement("TextLabel", {
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundColor3 = Color3.new(0, 0, 1),
						Text = "Page TwoA",
					}, {
						detailButton = Roact.createElement("TextButton", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.new(0.5, 0, 0.5, 30),
							Size = UDim2.new(0.5, 0, 0, 30),
							BackgroundColor3 = Color3.new(1, 1, 1),
							TextColor3 = Color3.new(0, 0, 0),
							TextSize = 18,
							Text = "Go to Detail B",
							[Roact.Event.Activated] = function()
								aProps.navigation.navigate("TwoB")
							end,
						}),
					})
				end,
			},
			{
				TwoB = function(bProps)
					return Roact.createElement("TextLabel", {
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundColor3 = Color3.new(1, 1, 0),
						Text = "Page TwoB",
					}, {
						backButton = Roact.createElement("TextButton", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.new(1, 1, 1),
							Size = UDim2.new(0, 160, 0, 30),
							Position = UDim2.new(0.5, 0, 0.5, 30),
							Text = "Go Back",
							TextColor3 = Color3.new(0, 0, 0),
							TextSize = 18,
							[Roact.Event.Activated] = function()
								bProps.navigation.goBack()
							end,
						}),
					})
				end,
			},
		})

		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(0.75, 0.75, 0.75),
		}, {
			StackOneFrame = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0.5, 0),
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, {
				AppContainer = Roact.createElement(RoactNavigation.createAppContainer(stackOneNavigator)),
			}),
			StackTwoFrame = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0.5, 0),
				Position = UDim2.new(0, 0, 0.5, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, {
				AppContainer = Roact.createElement(RoactNavigation.createAppContainer(stackTwoNavigator)),
			}),
		})
	end

	local rootElement = Roact.createElement(RootComponent)
	local rootInstance = Roact.mount(rootElement, target)

	return function()
		Roact.unmount(rootInstance)
	end
end
