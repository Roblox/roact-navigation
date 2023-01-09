local Storybook = script.Parent.Parent
local Packages = Storybook.Parent

local setupReactStory = require(Storybook.setupReactStory)
local React = require(Packages.React)
local RoactNavigation = require(Packages.RoactNavigation)

--[[
	This story demonstrates how to build a StackNavigator-based UI with a
	simple Top Bar. Please note that Roact Navigation only provides the
	core render surfaces. You should use a reusable toolkit for navigation aids!
]]
return function(target)
	local function MasterPage(props)
		local navigation = props.navigation

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
					navigation.navigate("Detail")
				end,
			}),
		})
	end

	local function DetailPage(props)
		local navigation = props.navigation
		local pushCount = navigation.getParam("pushCount", 0)

		return React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.Gotham,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0.5, 0, 0.5, 0),
			Text = "Detail Page",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
		}, {
			goNextDetailButton = React.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Size = UDim2.new(0, 160, 0, 30),
				Text = "Push next detail",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[React.Event.Activated] = function()
					navigation.navigate({
						routeName = "Detail",
						key = tostring(pushCount),
						params = {
							pushCount = pushCount + 1,
						},
					})
				end,
			}),
		})
	end

	local InnerNavigator = RoactNavigation.createRobloxStackNavigator({
		{
			Master = {
				screen = MasterPage,
				navigationOptions = { title = "Master" },
			},
		},
		{
			Detail = {
				screen = DetailPage,
				navigationOptions = function(navProps)
					local navigation = navProps.navigation
					return {
						title = "Detail " .. tostring(navigation.getParam("pushCount", 0)),
					}
				end,
			},
		},
	})

	local SimpleTopBarStackNavigator = React.Component:extend("SimpleTopBarStackNavigator")
	SimpleTopBarStackNavigator.router = InnerNavigator.router

	function SimpleTopBarStackNavigator:render()
		local navigation = self.props.navigation
		local options = RoactNavigation.getActiveChildNavigationOptions(navigation)
		local activeKey = navigation.state.routes[navigation.state.index].key
		local backButtonEnabled = navigation.state.index > 1

		return React.createElement("Folder", nil, {
			TopBar = React.createElement("TextLabel", {
				Text = options.title or "Unknown",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				Size = UDim2.new(1, 0, 0, 80),
				BackgroundColor3 = Color3.new(0.9, 0.9, 0.9),
				ZIndex = 1,
			}, {
				BackButton = React.createElement("TextButton", {
					Visible = backButtonEnabled,
					Active = backButtonEnabled,
					Size = UDim2.new(0, 64, 0, 64),
					Position = UDim2.new(0, 8, 0, 8),
					Text = "<--",
					[React.Event.Activated] = function()
						navigation.goBack(activeKey)
					end,
				}),
			}),
			NavigatorFrame = React.createElement("Frame", {
				Position = UDim2.new(0, 0, 0, 80),
				Size = UDim2.new(1, 0, 1, -80),
				ZIndex = 0,
			}, {
				InnerNavigator = React.createElement(InnerNavigator, {
					navigation = navigation,
				}),
			}),
		})
	end

	local appContainer = RoactNavigation.createAppContainer(SimpleTopBarStackNavigator)

	return setupReactStory(target, React.createElement(appContainer, { detached = true }))
end
