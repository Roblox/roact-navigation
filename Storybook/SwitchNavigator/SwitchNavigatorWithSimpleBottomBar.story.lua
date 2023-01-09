local Storybook = script.Parent.Parent
local Packages = Storybook.Parent

local setupReactStory = require(Storybook.setupReactStory)
local React = require(Packages.React)
local RoactNavigation = require(Packages.RoactNavigation)

--[[
	This story demonstrates how to build a SwitchNavigator-based UI with a
	simple Bottom Bar. Please note that Roact Navigation only provides the
	core render surfaces. You should use a reusable toolkit for navigation aids!
]]
return function(target)
	local function generatePageComponent(pageName)
		return function(_props)
			return React.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				TextSize = 18,
				TextColor3 = Color3.new(0, 0, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Text = pageName,
			})
		end
	end

	local function BarButtonItem(props)
		local onActivated = props.onActivated
		local selected = props.selected
		local totalCount = props.totalCount
		local index = props.index
		local title = props.title

		local width = 1 / totalCount
		return React.createElement("TextButton", {
			Size = UDim2.new(width, 0, 1, 0),
			Position = UDim2.new(width * (index - 1), 0, 0, 0),
			Text = title,
			TextSize = 18,
			TextColor3 = Color3.new(0, 0, 0),
			BackgroundColor3 = if selected then Color3.new(0, 1, 0) else Color3.new(1, 1, 1),
			[React.Event.Activated] = onActivated,
		})
	end

	local tabOrder = { "PageOne", "PageTwo", "PageThree" }

	local InnerNavigator = RoactNavigation.createRobloxSwitchNavigator({
		{ PageOne = generatePageComponent("PageOne") },
		{ PageTwo = generatePageComponent("PageTwo") },
		{ PageThree = generatePageComponent("PageThree") },
	}, {
		order = tabOrder,
	})

	local SimpleBottomBarSwitchNavigator = React.Component:extend("SimpleBottomBarSwitchNavigator")
	SimpleBottomBarSwitchNavigator.router = InnerNavigator.router

	function SimpleBottomBarSwitchNavigator:render()
		local navigation = self.props.navigation

		local buttons = {}
		for idx, pageName in tabOrder do
			table.insert(
				buttons,
				React.createElement(BarButtonItem, {
					title = pageName,
					totalCount = #tabOrder,
					index = idx,
					selected = idx == navigation.state.index,
					onActivated = function()
						navigation.navigate(pageName)
					end,
				})
			)
		end

		return React.createElement("Folder", nil, {
			NavigatorFrame = React.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, -80),
				ZIndex = 0,
			}, {
				InnerNavigator = React.createElement(InnerNavigator, {
					navigation = navigation,
				}),
			}),
			BottomBar = React.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 80),
				Position = UDim2.new(0, 0, 1, -80),
				BackgroundColor3 = Color3.new(0.9, 0.9, 0.9),
				ZIndex = 1,
			}, buttons),
		})
	end

	local appContainer = RoactNavigation.createAppContainer(SimpleBottomBarSwitchNavigator)
	local element = React.createElement(appContainer, { detached = true })

	return setupReactStory(target, element)
end
