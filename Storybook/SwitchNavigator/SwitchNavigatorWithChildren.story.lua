local Roact = require(script.Parent.Parent.Parent.Roact)
local RoactNavigation = require(script.Parent.Parent.Parent.RoactNavigation)

--[[
	This story demonstrates how to build a basic SwitchRouter-based UI, including
	child navigators. It creates the following UI hierarchy:

	AppContainer
		SwitchNavigator
			FirstPage
			SecondPage
			SwitchNavigator
				ThirdPage
				FourthPage

	Each page holds a button that navigates to the next page in sequence. FourthPage
	jumps back up to FirstPage, but sets the "extra title" param to show that the data
	for FirstPage can be customized dynamically. Said data defaults to initialRouteParams.
]]
return function(target)
	local FirstPage = Roact.Component:extend("FirstPage")

	function FirstPage:render()
		local navigation = self.props.navigation

		-- Use extraTitle param if it has been provided
		local extraTitle = navigation.getParam("extraTitle")

		local text = "Hello, Roact-Navigation page 1!"
		if extraTitle and #extraTitle > 0 then
			text = text .. " (" .. extraTitle .. ")"
		end

		return Roact.createElement("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1,1,1),
			Font = Enum.Font.Gotham,
			Position = UDim2.new(0.5,0,0.5,0),
			Size = UDim2.new(0.5,0,0.25,0),
			Text = text,
			TextColor3 = Color3.new(0,0,0),
			TextSize = 18,
			[Roact.Event.Activated] = function()
				navigation.navigate("Page2")
			end,
		})
	end

	-- We can declare components functionally too!
	local function SecondPage(props)
		return Roact.createElement("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1,1,1),
			Font = Enum.Font.Gotham,
			Position = UDim2.new(0.5,0,0.5,0),
			Size = UDim2.new(0.5,0,0.25,0),
			Text = "Hello, Roact-Navigation page 2!",
			TextColor3 = Color3.new(0,0,0),
			TextSize = 18,
			[Roact.Event.Activated] = function()
				props.navigation.navigate("Page3")
			end,
		})
	end

	local ThirdPage = Roact.Component:extend("ThirdPage")

	function ThirdPage:render()
		local navigation = self.props.navigation
		local extraTitle = navigation.getParam("extraTitle")

		local text = "Hello, Roact-Navigation page 3A!"
		if extraTitle and #extraTitle > 0 then
			text = text .. " (" .. extraTitle .. ")"
		end

		return Roact.createElement("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1,1,1),
			Font = Enum.Font.Gotham,
			Position = UDim2.new(0.5,0,0.5,0),
			Size = UDim2.new(0.5,0,0.25,0),
			Text = text,
			TextColor3 = Color3.new(0,0,0),
			TextSize = 18,
			[Roact.Event.Activated] = function()
				navigation.navigate("Page3B")
			end,
		})
	end

	local function FourthPage(props)
		local navigation = props.navigation

		return Roact.createElement("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1,1,1),
			Font = Enum.Font.Gotham,
			Position = UDim2.new(0.5,0,0.5,0),
			Size = UDim2.new(0.5,0,0.25,0),
			Text = "Hello, Roact-Navigation page 3B!",
			TextColor3 = Color3.new(0,0,0),
			TextSize = 18,
			[Roact.Event.Activated] = function()
				navigation.navigate("Page1", {
					extraTitle = "take 2", -- set param for the new Page1
				})
			end,
		})
	end

	-- This is the second-level navigator that holds Third+Fourth pages.
	-- Note that each navigator has its own initialRouteName and initialRouteParams.
	local ThirdPageNavigator = RoactNavigation.createRobloxSwitchNavigator({
		{ Page3A = ThirdPage },
		{ Page3B = FourthPage },
	}, {
		initialRouteParams = {
			extraTitle = "extra title",
		},
	})

	-- This is the top-level navigator. Note that child navigators are just Roact
	-- Components attached like any other route.
	local rootNavigator = RoactNavigation.createRobloxSwitchNavigator({
		{ Page1 = FirstPage },
		{ Page2 = SecondPage },
		{ Page3 = ThirdPageNavigator },
	})

	-- Navigators must all live under a single top-level container. The container
	-- provides the state tracking and action dispatching facilities that are the
	-- glue needed to make everything work. You can (probably) add additional app containers
	-- in sub-screens in order to create a completely different navigation hierarchy
	-- if you want to, but then they wouldn't integrate into the history management!
	local appContainer = RoactNavigation.createAppContainer(rootNavigator)

	-- The app container can be mounted at root level, or you can stick it inside
	-- any other Roact component if you need extra structure.
	local rootInstance = Roact.mount(Roact.createElement(appContainer), target)

	return function()
		Roact.unmount(rootInstance)
	end
end
