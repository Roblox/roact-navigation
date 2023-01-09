local Storybook = script.Parent.Parent
local Packages = Storybook.Parent

local setupReactStory = require(Storybook.setupReactStory)
local React = require(Packages.React)
local RoactNavigation = require(Packages.RoactNavigation)

--[[
	This story demonstrates how to create a SwitchNavigator that will keep its
	pages mounted after they have been visited once.
]]
return function(target)
	local MyFirstPage = React.Component:extend("MyFirstPage")

	function MyFirstPage:render()
		local navigation = self.props.navigation

		return React.createElement("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.Gotham,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0.5, 0, 0.25, 0),
			Text = navigation.state.key,
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
			[React.Event.Activated] = function()
				navigation.navigate("MySecondPage")
			end,
		})
	end

	function MyFirstPage:didMount()
		print("First page mounted!")
	end

	function MyFirstPage:willUnmount()
		print("First page unmounted!")
	end

	local MySecondPage = React.Component:extend("MySecondPage")
	function MySecondPage:render()
		local navigation = self.props.navigation

		return React.createElement("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.Gotham,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0.5, 0, 0.25, 0),
			Text = navigation.state.key,
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
			[React.Event.Activated] = function()
				navigation.navigate("MyFirstPage")
			end,
		})
	end

	function MySecondPage:didMount()
		print("Second page mounted!")
	end

	function MySecondPage:willUnmount()
		print("Second page unmounted!")
	end

	local navigator = RoactNavigation.createRobloxSwitchNavigator({
		{ MyFirstPage = MyFirstPage },
		{ MySecondPage = MySecondPage },
	}, {
		keepVisitedScreensMounted = true, -- This is the important flag!
	})

	local appContainer = RoactNavigation.createAppContainer(navigator)
	local element = React.createElement(appContainer, { detached = true })

	return setupReactStory(target, element)
end
