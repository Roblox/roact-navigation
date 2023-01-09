local Storybook = script.Parent.Parent
local Packages = Storybook.Parent

local setupReactStory = require(Storybook.setupReactStory)
local React = require(Packages.React)
local RoactNavigation = require(Packages.RoactNavigation)

--[[
	This story demonstrates how to build a screen component that uses the
	withNavigationFocus() helper to alter its UI when the page is focused
	or unfocused. We use a simple master-detail stack navigator as the basis:

	AppContainer
		StackNavigator
			MasterPage
			DetailPage
]]
return function(target)
	local MasterPage = React.Component:extend("MasterPage")

	function MasterPage:render()
		local navigation = self.props.navigation
		return React.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Text = "Master Page",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
		}, {
			detailButton = React.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Size = UDim2.new(0, 160, 0, 30),
				Text = "Go to Detail",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[React.Event.Activated] = function()
					-- Note that you can push() to force a new instance, instead!
					navigation.navigate("Detail")
				end,
			}),
		})
	end

	-- We can declare components functionally too!
	local function DetailPage(props)
		local navigation = props.navigation
		local isFocused = props.isFocused

		return React.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = if isFocused then Color3.new(0, 1, 0) else Color3.new(1, 0, 0),
		}, {
			backButton = React.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Size = UDim2.new(0, 160, 0, 30),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Text = "Go Back",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[React.Event.Activated] = function()
					navigation.goBack()
				end,
			}),
		})
	end

	-- This is the top-level navigator. Note that child navigators are just Roact
	-- Components attached like any other route.
	local rootNavigator = RoactNavigation.createRobloxStackNavigator({
		{ Master = RoactNavigation.withNavigation(MasterPage) },
		{ Detail = RoactNavigation.withNavigationFocus(DetailPage) },
	})

	local appContainer = RoactNavigation.createAppContainer(rootNavigator)

	return setupReactStory(target, React.createElement(appContainer, { detached = true }))
end
