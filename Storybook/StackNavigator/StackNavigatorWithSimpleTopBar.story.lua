local Roact = require(script.Parent.Parent.Parent.Roact)
local RoactNavigation = require(script.Parent.Parent.Parent.RoactNavigation)

--[[
	This story demonstrates how to build a StackNavigator-based UI with a
	simple Top Bar. Please note that Roact Navigation only provides the
	core render surfaces. You should use a reusable toolkit for navigation aids!
]]
return function(target)
	local function MasterPage(props)
		local navigation = props.navigation

		return Roact.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Text = "Master Page",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
		}, {
			detailButton = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Size = UDim2.new(0, 160, 0, 30),
				Text = "Go to Detail",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					navigation.navigate("Detail")
				end
			})
		})
	end

	local function DetailPage(props)
		local navigation = props.navigation
		local pushCount = navigation.getParam("pushCount", 0)

		return Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.Gotham,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0.5, 0, 0.5, 0),
			Text = "Detail Page",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
		}, {
			goNextDetailButton = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Size = UDim2.new(0, 160, 0, 30),
				Text = "Push next detail",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					navigation.push("Detail", { pushCount = pushCount + 1 })
				end,
			}),
		})
	end

	local InnerNavigator = RoactNavigation.createStackNavigator({
		routes = {
			Master = {
				screen = MasterPage,
				navigationOptions = { title = "Master" },
			},
			Detail = {
				screen = DetailPage,
				navigationOptions = function(navProps)
					local navigation = navProps.navigation
					return {
						title = "Detail " .. tostring(navigation.getParam("pushCount", 0))
					}
				end,
			},
		},
		initialRouteName = "Master",
	})

	local SimpleTopBarStackNavigator = Roact.Component:extend("SimpleTopBarStackNavigator")
	SimpleTopBarStackNavigator.router = InnerNavigator.router

	function SimpleTopBarStackNavigator:render()
		local navigation = self.props.navigation
		local options = RoactNavigation.getActiveChildNavigationOptions(navigation)
		local activeKey = navigation.state.routes[navigation.state.index].key
		local backButtonEnabled = navigation.state.index > 1

		return Roact.createElement("Folder", nil, {
			TopBar = Roact.createElement("TextLabel", {
				Text = options.title or "Unknown",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				Size = UDim2.new(1, 0, 0, 80),
				BackgroundColor3 = Color3.new(0.9, 0.9, 0.9),
				ZIndex = 1,
			}, {
				BackButton = Roact.createElement("TextButton", {
					Visible = backButtonEnabled,
					Active = backButtonEnabled,
					Size = UDim2.new(0, 64, 0, 64),
					Position = UDim2.new(0, 8, 0, 8),
					Text = "<--",
					[Roact.Event.Activated] = function()
						navigation.goBack(activeKey)
					end,
				}),
			}),
			NavigatorFrame = Roact.createElement("Frame", {
				Position = UDim2.new(0, 0, 0, 80),
				Size = UDim2.new(1, 0, 1, -80),
				ZIndex = 0,
			}, {
				InnerNavigator = Roact.createElement(InnerNavigator, {
					navigation = navigation,
				}),
			}),
		})
	end

	local appContainer = RoactNavigation.createAppContainer(SimpleTopBarStackNavigator)
	local rootInstance = Roact.mount(Roact.createElement(appContainer), target)

	return function()
		Roact.unmount(rootInstance)
	end
end
