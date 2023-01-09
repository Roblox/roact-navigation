local Storybook = script.Parent.Parent
local Packages = Storybook.Parent

local setupReactStory = require(Storybook.setupReactStory)
local React = require(Packages.React)
local RoactNavigation = require(Packages.RoactNavigation)

--[[
	This story demonstrates how to build a basic StackNavigator-based UI. It creates
	the following hierarchy:

	AppContainer
		StackNavigator
			MasterPage
			DetailPage = StackNavigator
				DetailPageA
				DetailPageB
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
					navigation.navigate("Detail") -- goes to initial page for the subnavigator
				end,
			}),
		})
	end

	local function SubDetailPageA(props)
		local navigation = props.navigation

		return React.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.Gotham,
			Text = "SubDetail Page A",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
		}, {
			subDetailButton = React.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Size = UDim2.new(0, 160, 0, 30),
				Text = "Go to subdetail B",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[React.Event.Activated] = function()
					navigation.navigate("SubDetailB")
				end,
			}),
		})
	end

	local function SubDetailPageB(props)
		local navigation = props.navigation

		return React.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.Gotham,
			Text = "SubDetail Page B",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
		}, {
			backToMasterButton = React.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Size = UDim2.new(0, 160, 0, 30),
				Text = "Go back to Master",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[React.Event.Activated] = function()
					navigation.navigate("Master")
				end,
			}),
		})
	end

	local DetailPageNavigator = RoactNavigation.createRobloxStackNavigator({
		{ SubDetailA = SubDetailPageA },
		{ SubDetailB = SubDetailPageB },
	})

	local rootNavigator = RoactNavigation.createRobloxStackNavigator({
		{ Master = MasterPage },
		{ Detail = DetailPageNavigator },
	})

	local appContainer = RoactNavigation.createAppContainer(rootNavigator)

	return setupReactStory(target, React.createElement(appContainer, { detached = true }))
end
