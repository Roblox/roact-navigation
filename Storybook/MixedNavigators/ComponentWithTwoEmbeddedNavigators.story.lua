local Storybook = script.Parent.Parent
local Packages = Storybook.Parent

local setupReactStory = require(Storybook.setupReactStory)
local React = require(Packages.React)
local RoactNavigation = require(Packages.RoactNavigation)

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
					return React.createElement("TextLabel", {
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundColor3 = Color3.new(1, 0, 0),
						Text = "Page OneA",
					}, {
						detailButton = React.createElement("TextButton", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.new(0.5, 0, 0.5, 30),
							Size = UDim2.new(0.5, 0, 0, 30),
							BackgroundColor3 = Color3.new(1, 1, 1),
							TextColor3 = Color3.new(0, 0, 0),
							TextSize = 18,
							Text = "Go to Detail B",
							[React.Event.Activated] = function()
								aProps.navigation.navigate("OneB")
							end,
						}),
					})
				end,
			},
			{
				OneB = function(bProps)
					return React.createElement("TextLabel", {
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundColor3 = Color3.new(0, 1, 0),
						Text = "Page OneB",
					}, {
						backButton = React.createElement("TextButton", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.new(1, 1, 1),
							Size = UDim2.new(0, 160, 0, 30),
							Position = UDim2.new(0.5, 0, 0.5, 30),
							Text = "Go Back",
							TextColor3 = Color3.new(0, 0, 0),
							TextSize = 18,
							[React.Event.Activated] = function()
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
					return React.createElement("TextLabel", {
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundColor3 = Color3.new(0, 0, 1),
						Text = "Page TwoA",
					}, {
						detailButton = React.createElement("TextButton", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.new(0.5, 0, 0.5, 30),
							Size = UDim2.new(0.5, 0, 0, 30),
							BackgroundColor3 = Color3.new(1, 1, 1),
							TextColor3 = Color3.new(0, 0, 0),
							TextSize = 18,
							Text = "Go to Detail B",
							[React.Event.Activated] = function()
								aProps.navigation.navigate("TwoB")
							end,
						}),
					})
				end,
			},
			{
				TwoB = function(bProps)
					return React.createElement("TextLabel", {
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundColor3 = Color3.new(1, 1, 0),
						Text = "Page TwoB",
					}, {
						backButton = React.createElement("TextButton", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.new(1, 1, 1),
							Size = UDim2.new(0, 160, 0, 30),
							Position = UDim2.new(0.5, 0, 0.5, 30),
							Text = "Go Back",
							TextColor3 = Color3.new(0, 0, 0),
							TextSize = 18,
							[React.Event.Activated] = function()
								bProps.navigation.goBack()
							end,
						}),
					})
				end,
			},
		})

		return React.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(0.75, 0.75, 0.75),
		}, {
			StackOneFrame = React.createElement("Frame", {
				Size = UDim2.new(1, 0, 0.5, 0),
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, {
				AppContainer = React.createElement(RoactNavigation.createAppContainer(stackOneNavigator)),
			}),
			StackTwoFrame = React.createElement("Frame", {
				Size = UDim2.new(1, 0, 0.5, 0),
				Position = UDim2.new(0, 0, 0.5, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, {
				AppContainer = React.createElement(RoactNavigation.createAppContainer(stackTwoNavigator)),
			}),
		})
	end

	local rootElement = React.createElement(RootComponent)

	return setupReactStory(target, rootElement)
end
