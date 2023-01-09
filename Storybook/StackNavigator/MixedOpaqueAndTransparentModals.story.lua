local Storybook = script.Parent.Parent
local Packages = Storybook.Parent

local setupReactStory = require(Storybook.setupReactStory)
local React = require(Packages.React)
local RoactNavigation = require(Packages.RoactNavigation)

--[[
	This story demonstrates the combination of transparent (overlayEnabled)
	modals mixed with opaque modals to show how they interact.

	AppContainer
		StackNavigator(Modal)
			MainContent
			OpaqueModalDialog
			TransparentModalDialog
]]
return function(target)
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
			showOpaqueModalButton = React.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Size = UDim2.new(0, 220, 0, 30),
				Text = "Show Opaque Modal",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[React.Event.Activated] = function()
					navigation.navigate("OpaqueModalDialog")
				end,
			}),
			showTransparentModalButton = React.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 30),
				Size = UDim2.new(0, 220, 0, 30),
				Text = "Show Transparent Modal",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[React.Event.Activated] = function()
					navigation.navigate("TransparentModalDialog")
				end,
			}),
		})
	end

	-- Note that we are sharing the ModalDialog component and getting different behavior
	-- using different route configs!
	local function ModalDialog(props)
		local navigation = props.navigation
		local dialogCount = navigation.getParam("dialogCount", 0)

		-- Note that we are NOT making the screen component itself opaque.
		-- The opaque background comes from cardColor3 in navigationOptions!
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
				Text = "Dialog " .. tostring(dialogCount),
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
			}, {
				pushOpaqueModalButton = React.createElement("TextButton", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.new(1, 1, 1),
					Font = Enum.Font.Gotham,
					Position = UDim2.new(0.5, 0, 0.6, 0),
					Size = UDim2.new(0, 220, 0, 30),
					Text = "Push Opaque Modal",
					TextColor3 = Color3.new(0, 0, 0),
					TextSize = 18,
					[React.Event.Activated] = function()
						navigation.navigate({
							routeName = "OpaqueModalDialog",
							-- having the same key as the transparent dialog will
							-- prevent pushing both of the dialogs if we click
							-- really fast on both buttons
							key = ("Dialog-%d"):format(dialogCount + 1),
							params = { dialogCount = dialogCount + 1 },
						})
					end,
				}),
				pushTransparentModalButton = React.createElement("TextButton", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.new(1, 1, 1),
					Font = Enum.Font.Gotham,
					Position = UDim2.new(0.5, 0, 0.6, 30),
					Size = UDim2.new(0, 220, 0, 30),
					Text = "Push Transparent Modal",
					TextColor3 = Color3.new(0, 0, 0),
					TextSize = 18,
					[React.Event.Activated] = function()
						navigation.navigate({
							routeName = "TransparentModalDialog",
							-- having the same key as the opaque dialog will
							-- prevent pushing both of the dialogs if we click
							-- really fast on both buttons
							key = ("Dialog-%d"):format(dialogCount + 1),
							params = { dialogCount = dialogCount + 1 },
						})
					end,
				}),
				popToTopModalButton = React.createElement("TextButton", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.new(1, 1, 1),
					Font = Enum.Font.Gotham,
					Position = UDim2.new(0.5, 0, 0.6, 60),
					Size = UDim2.new(0, 220, 0, 30),
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
					Position = UDim2.new(0.5, 0, 0.6, 90),
					Size = UDim2.new(0, 220, 0, 30),
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

	local rootNavigator = RoactNavigation.createRobloxStackNavigator({
		{ MainContent = MainContent },
		{
			OpaqueModalDialog = {
				screen = ModalDialog,
				navigationOptions = function(navProps)
					local dialogCount = navProps.navigation.getParam("dialogCount", 0)
					return {
						cardColor3 = Color3.fromRGB(0, 0, 255 - 15 * dialogCount),
					}
				end,
			},
		},
		{
			TransparentModalDialog = {
				screen = ModalDialog,
				navigationOptions = {
					overlayEnabled = true,
				},
			},
		},
	}, {
		mode = RoactNavigation.StackPresentationStyle.Modal,
	})
	local appContainer = RoactNavigation.createAppContainer(rootNavigator)

	return setupReactStory(target, React.createElement(appContainer, { detached = true }))
end
