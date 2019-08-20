local Roact = require(script.Parent.Parent.Parent.Roact)
local RoactNavigation = require(script.Parent.Parent.Parent.RoactNavigation)

--[[
	This story demonstrates how to build modal dialogs using a StackNavigator.
	It creates the following hierarchy:

	AppContainer
		StackNavigator(Modal)
			MainContent
			ExampleModalDialog
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
				Size = UDim2.new(0, 160, 0, 30),
				Text = "Show the Modal",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					navigation.navigate("ModalDialog")
				end
			})
		})
	end

	local function ModalDialog(props)
		local navigation = props.navigation

		return Roact.createElement("TextLabel", {
			BackgroundColor3 = Color3.new(0.9, 0.9, 0.9),
			Font = Enum.Font.Gotham,
			Size = UDim2.new(1, 0, 1, 0),
			Text = "This is the modal dialog",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
		}, {
			dismissModalButton = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Size = UDim2.new(0, 160, 0, 30),
				Text = "Dismiss",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					-- We use goBack to dismiss an entry in the current stack. You only use
					-- navigation.dismiss() if you want to dismiss from INSIDE another navigator, e.g.
					-- if your modal is actually its own stack navigator.
					navigation.goBack()
				end,
			}),
		})
	end

	-- When you want to show modal dialogs, you create a top-level StackNavigator
	-- with mode=StackPresentationStyle.Modal. Your main app content goes inside
	-- a Page or navigator at this level. Note that to hide the automatic top bar
	-- for the root stack navigator, you have to set headerMode=StackHeaderMode.None.
	local rootNavigator = RoactNavigation.createTopBarStackNavigator({
		routes = {
			MainContent = MainContent,
			ModalDialog = ModalDialog,
		},
		initialRouteName = "MainContent",
		mode = RoactNavigation.StackPresentationStyle.Modal,
		headerMode = RoactNavigation.StackHeaderMode.None,
	})
	local appContainer = RoactNavigation.createAppContainer(rootNavigator)
	local rootInstance = Roact.mount(Roact.createElement(appContainer), target)

	return function()
		Roact.unmount(rootInstance)
	end
end
