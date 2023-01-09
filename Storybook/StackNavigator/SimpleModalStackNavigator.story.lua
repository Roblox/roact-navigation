local Storybook = script.Parent.Parent
local Packages = Storybook.Parent

local setupReactStory = require(Storybook.setupReactStory)
local React = require(Packages.React)
local RoactNavigation = require(Packages.RoactNavigation)
local LuauPolyfill = require(Packages.LuauPolyfill)
local Object = LuauPolyfill.Object

--[[
	This story demonstrates how to build modal dialogs using a StackNavigator.
	It creates the following hierarchy:

	AppContainer
		StackNavigator(Modal)
			MainContent
			ExampleModalDialog
]]
return function(target, navigatorConfig)
	local function MainContent(props)
		local navigation = props.navigation

		return React.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(1, 1, 0),
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Text = "Main App Content",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
		}, {
			showModalButton = React.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Size = UDim2.new(0, 160, 0, 30),
				Text = "Show the Modal",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[React.Event.Activated] = function()
					navigation.navigate("ModalDialog")
				end,
			}),
		})
	end

	local function ModalDialog(props)
		local navigation = props.navigation
		local dialogCount = navigation.getParam("dialogCount", 0)

		return React.createElement("Frame", {
			Size = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
		}, {
			dialog = React.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Size = UDim2.new(0.5, 0, 0.5, 0),
				Text = "Modal Dialog " .. tostring(dialogCount),
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
			}, {
				pushAnotherModalButton = React.createElement("TextButton", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.new(1, 1, 1),
					Font = Enum.Font.Gotham,
					Position = UDim2.new(0.5, 0, 0.6, 0),
					Size = UDim2.new(0, 160, 0, 30),
					Text = "Push Another",
					TextColor3 = Color3.new(0, 0, 0),
					TextSize = 18,
					[React.Event.Activated] = function()
						navigation.navigate({
							routeName = "ModalDialog",
							-- using a unique key will avoid pushing the same dialog
							-- multiple times if we're clicking really fast
							key = ("ModalDialog-%d"):format(dialogCount + 1),
							params = { dialogCount = dialogCount + 1 },
						})
					end,
				}),
				popToTopModalButton = React.createElement("TextButton", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.new(1, 1, 1),
					Font = Enum.Font.Gotham,
					Position = UDim2.new(0.5, 0, 0.6, 30),
					Size = UDim2.new(0, 160, 0, 30),
					Text = "Pop to Top",
					TextColor3 = Color3.new(0, 0, 0),
					TextSize = 18,
					[React.Event.Activated] = function()
						navigation.popToTop()
					end,
				}),
				dismissModalButton = React.createElement("TextButton", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.new(1, 1, 1),
					Font = Enum.Font.Gotham,
					Position = UDim2.new(0.5, 0, 0.6, 60),
					Size = UDim2.new(0, 160, 0, 30),
					Text = "Dismiss",
					TextColor3 = Color3.new(0, 0, 0),
					TextSize = 18,
					[React.Event.Activated] = function()
						-- We use goBack to dismiss an entry in the current stack. You only use
						-- navigation.dismiss() if you want to dismiss from INSIDE another navigator, e.g.
						-- if your modal is actually its own stack navigator.
						navigation.goBack()
					end,
				}),
			}),
		})
	end

	-- When you want to show modal dialogs, you create a top-level StackNavigator
	-- with mode=StackPresentationStyle.Modal. Your main app content goes inside
	-- a Page or navigator at this level. Note that to hide the automatic top bar
	-- for the root stack navigator, you have to set headerMode=StackHeaderMode.None.
	local _ref = {
		mode = RoactNavigation.StackPresentationStyle.Modal,
	}
	local rootNavigator = RoactNavigation.createRobloxStackNavigator({
		{ MainContent = MainContent },
		{
			ModalDialog = {
				screen = ModalDialog,
				navigationOptions = {
					-- Draw an overlay effect under this page.
					-- You may use overlayColor3 to set a custom overlay color, and
					-- overlayTransparency to set a custom darkening amount if you
					-- need specific settings.
					overlayEnabled = true,
				},
			},
		},
	}, if navigatorConfig then Object.assign(table.clone(navigatorConfig), _ref) else _ref)

	local appContainer = RoactNavigation.createAppContainer(rootNavigator)

	return setupReactStory(target, React.createElement(appContainer, { detached = true }))
end
