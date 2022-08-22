local Roact = require(script.Parent.Parent.Parent.Roact)
local RoactNavigation = require(script.Parent.Parent.Parent.RoactNavigation)

--[[
	This story demonstrates how to create a SwitchNavigator that will keep its
	pages mounted after they have been visited once.
]]
return function(target)
	local MyFirstPage = Roact.Component:extend("MyFirstPage")

	function MyFirstPage:render()
		local navigation = self.props.navigation

		return Roact.createElement("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.Gotham,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0.5, 0, 0.25, 0),
			Text = navigation.state.key,
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
			[Roact.Event.Activated] = function()
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

	local MySecondPage = Roact.Component:extend("MySecondPage")
	function MySecondPage:render()
		local navigation = self.props.navigation

		return Roact.createElement("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.Gotham,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0.5, 0, 0.25, 0),
			Text = navigation.state.key,
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
			[Roact.Event.Activated] = function()
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
	local element = Roact.createElement(appContainer)
	local rootInstance = Roact.mount(element, target)

	return function()
		Roact.unmount(rootInstance)
	end
end
