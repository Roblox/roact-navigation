local Roact = require(script.Parent.Parent.Parent.Roact)
local RoactNavigation = require(script.Parent.Parent.Parent.RoactNavigation)

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

		return Roact.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(1, 1, 0),
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Text = "Main App Content",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
		}, {
			showOpaqueModalButton = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Size = UDim2.new(0, 220, 0, 30),
				Text = "Show Opaque Modal",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					navigation.navigate("OpaqueModalDialog")
				end
			}),
			showTransparentModalButton = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 30),
				Size = UDim2.new(0, 220, 0, 30),
				Text = "Show Transparent Modal",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					navigation.navigate("TransparentModalDialog")
				end
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
		return Roact.createElement("Frame", {
			Size = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
		}, {
			dialog = Roact.createElement("TextLabel", {
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
				pushOpaqueModalButton = Roact.createElement("TextButton", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.new(1, 1, 1),
					Font = Enum.Font.Gotham,
					Position = UDim2.new(0.5, 0, 0.6, 0),
					Size = UDim2.new(0, 220, 0, 30),
					Text = "Push Opaque Modal",
					TextColor3 = Color3.new(0, 0, 0),
					TextSize = 18,
					[Roact.Event.Activated] = function()
						navigation.push("OpaqueModalDialog", {
							dialogCount = dialogCount + 1,
						})
					end,
				}),
				pushTransparentModalButton = Roact.createElement("TextButton", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.new(1, 1, 1),
					Font = Enum.Font.Gotham,
					Position = UDim2.new(0.5, 0, 0.6, 30),
					Size = UDim2.new(0, 220, 0, 30),
					Text = "Push Transparent Modal",
					TextColor3 = Color3.new(0, 0, 0),
					TextSize = 18,
					[Roact.Event.Activated] = function()
						navigation.push("TransparentModalDialog", {
							dialogCount = dialogCount + 1,
						})
					end,
				}),
				popToTopModalButton = Roact.createElement("TextButton", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.new(1, 1, 1),
					Font = Enum.Font.Gotham,
					Position = UDim2.new(0.5, 0, 0.6, 60),
					Size = UDim2.new(0, 220, 0, 30),
					Text = "Pop to Top",
					TextColor3 = Color3.new(0, 0, 0),
					TextSize = 18,
					[Roact.Event.Activated] = function()
						navigation.popToTop()
					end,
				}),
				dismissModalButton = Roact.createElement("TextButton", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.new(1, 1, 1),
					Font = Enum.Font.Gotham,
					Position = UDim2.new(0.5, 0, 0.6, 90),
					Size = UDim2.new(0, 220, 0, 30),
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
		})
	end

	local rootNavigator = RoactNavigation.createStackNavigator({
		routes = {
			MainContent = MainContent,
			OpaqueModalDialog = {
				screen = ModalDialog,
				navigationOptions = function(navProps)
					local dialogCount = navProps.navigation.getParam("dialogCount", 0)
					return {
						cardColor3 = Color3.fromRGB(0, 0, 255 - 15*dialogCount),
					}
				end,
			},
			TransparentModalDialog = {
				screen = ModalDialog,
				navigationOptions = {
					overlayEnabled = true,
				}
			},
		},
		initialRouteName = "MainContent",
		mode = RoactNavigation.StackPresentationStyle.Modal,
	})
	local appContainer = RoactNavigation.createAppContainer(rootNavigator)
	local rootInstance = Roact.mount(Roact.createElement(appContainer), target)

	return function()
		Roact.unmount(rootInstance)
	end
end
