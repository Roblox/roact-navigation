local Roact = require(script.Parent.Parent.Parent.Roact)
local RoactNavigation = require(script.Parent.Parent.Parent.RoactNavigation)

--[[
	This story demonstrates how to build a modal dialog that has its own
	navigation stack.

	AppContainer
		StackNavigator(Modal)
			MainContent
			ModalDialog = StackNavigator
				ModalPageOne
				ModalPageTwo
]]
return function(target)
	local function MainContent(props)
		local navigation = props.navigation

		return Roact.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Text = "Main App Content",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
		}, {
			showModalButton = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Size = UDim2.new(0, 200, 0, 30),
				Text = "Show the Modal",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					navigation.navigate("ModalDialog")
				end
			})
		})
	end

	local function PageOne(props)
		local navigation = props.navigation

		return Roact.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Text = "Page 1",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
		}, {
			showModalButton = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Size = UDim2.new(0, 200, 0, 30),
				Text = "Go to Modal Page 2",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					navigation.navigate("PageTwo")
				end
			})
		})
	end

	local function PageTwo(props)
		local navigation = props.navigation

		return Roact.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Text = "Page 2",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
		}, {
			dismissButton = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Size = UDim2.new(0, 200, 0, 30),
				Text = "Dismiss Modal Dialog",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					-- Dismiss pops this entire inner stack by directing a Back action to
					-- the parent navigator.
					navigation.dismiss()
				end
			})
		})
	end

	local ModalNavigator = RoactNavigation.createRobloxStackNavigator({
		{ PageOne = PageOne },
		{ PageTwo = PageTwo },
	})

	-- When you want to show modal dialogs, you create a top-level StackNavigator
	-- with mode=StackPresentationStyle.Modal. Your main app content goes inside
	-- a Page or navigator at this level.
	local rootNavigator = RoactNavigation.createRobloxStackNavigator({
		{ MainContent = MainContent },
		{ ModalDialog = ModalNavigator },
	}, {
		mode = RoactNavigation.StackPresentationStyle.Modal,
	})
	local appContainer = RoactNavigation.createAppContainer(rootNavigator)
	local rootInstance = Roact.mount(Roact.createElement(appContainer), target)

	return function()
		Roact.unmount(rootInstance)
	end
end
