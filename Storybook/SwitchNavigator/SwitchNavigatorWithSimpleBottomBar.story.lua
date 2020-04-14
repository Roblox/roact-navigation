local Roact = require(script.Parent.Parent.Parent.Roact)
local RoactNavigation = require(script.Parent.Parent.Parent.RoactNavigation)

--[[
	This story demonstrates how to build a SwitchNavigator-based UI with a
	simple Bottom Bar. Please note that Roact Navigation only provides the
	core render surfaces. You should use a reusable toolkit for navigation aids!
]]
return function(target)
	local function generatePageComponent(pageName)
		return function(props)
			return Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				TextSize = 18,
				TextColor3 = Color3.new(0, 0, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Text = pageName,
			})
		end
	end

	local function BarButtonItem(props)
		local selected = props.selected
		return RoactNavigation.withNavigation(function(navigation)
			local width = 1 / props.totalCount
			return Roact.createElement("TextButton", {
				Size = UDim2.new(width, 0, 1, 0),
				Position = UDim2.new(width * (props.index - 1), 0, 0, 0),
				Text = props.pageName,
				TextSize = 18,
				TextColor3 = Color3.new(0, 0, 0),
				BackgroundColor3 = selected and Color3.new(0, 1, 0) or Color3.new(1, 1, 1),
				[Roact.Event.Activated] = function()
					navigation.navigate(props.pageName)
				end,
			})
		end)
	end

	local tabOrder = { "PageOne", "PageTwo", "PageThree" }

	local InnerNavigator = RoactNavigation.createSwitchNavigator({
		routes = {
			PageOne = generatePageComponent("PageOne"),
			PageTwo = generatePageComponent("PageTwo"),
			PageThree = generatePageComponent("PageThree"),
		},
		order = tabOrder,
		initialRouteName = "PageOne",
	})

	local SimpleBottomBarSwitchNavigator = Roact.Component:extend("SimpleBottomBarSwitchNavigator")
	SimpleBottomBarSwitchNavigator.router = InnerNavigator.router

	function SimpleBottomBarSwitchNavigator:render()
		local navigation = self.props.navigation

		local buttons = {}
		for idx, pageName in ipairs(tabOrder) do
			table.insert(buttons, Roact.createElement(BarButtonItem, {
				pageName = pageName,
				totalCount = #tabOrder,
				index = idx,
				selected = idx == navigation.state.index,
			}))
		end

		return Roact.createElement("Folder", nil, {
			NavigatorFrame = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, -80),
				ZIndex = 0,
			}, {
				InnerNavigator = Roact.createElement(InnerNavigator, {
					navigation = navigation,
				}),
			}),
			BottomBar = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 80),
				Position = UDim2.new(0, 0, 1, -80),
				BackgroundColor3 = Color3.new(0.9, 0.9, 0.9),
				ZIndex = 1,
			}, buttons)
		})
	end

	local appContainer = RoactNavigation.createAppContainer(SimpleBottomBarSwitchNavigator)
	local element = Roact.createElement(appContainer)
	local rootInstance = Roact.mount(element, target)

	return function()
		Roact.unmount(rootInstance)
	end
end
