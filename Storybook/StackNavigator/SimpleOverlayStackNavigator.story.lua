local Storybook = script.Parent.Parent
local Packages = Storybook.Parent

local setupReactStory = require(Storybook.setupReactStory)
local React = require(Packages.React)
local RoactNavigation = require(Packages.RoactNavigation)
local LuauPolyfill = require(Packages.LuauPolyfill)
local Object = LuauPolyfill.Object

--[[
	This story demonstrates how to build overlay dialogs using a StackNavigator.
	This differs from SimpleModalStackNavigator in that overlays animate in place
	rather than rising from bottom. It creates the following hierarchy:

	AppContainer
		StackNavigator(Overlay)
			MainContent
			OverlayDialog
]]
return function(target, navigatorOptions)
	navigatorOptions = navigatorOptions or {}

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
			showOverlayButton = React.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Size = UDim2.new(0, 160, 0, 30),
				Text = "Show the Overlay",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[React.Event.Activated] = function()
					navigation.navigate("OverlayDialog")
				end,
			}),
		})
	end

	local function OverlayDialog(props)
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
				Text = "Overlay Dialog " .. tostring(dialogCount),
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
			}, {
				pushAnotherOverlayButton = React.createElement("TextButton", {
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
							routeName = "OverlayDialog",
							-- using a unique key will avoid pushing the same dialog
							-- multiple times if we're clicking really fast
							key = ("Dialog-%d"):format(dialogCount + 1),
							params = { dialogCount = dialogCount + 1 },
						})
					end,
				}),
				popToTopOverlayButton = React.createElement("TextButton", {
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
				dismissOverlayButton = React.createElement("TextButton", {
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
						-- if your overlay is actually its own stack navigator.
						navigation.goBack()
					end,
				}),
			}),
		})
	end

	-- When you want to show overlay dialogs, you create a top-level StackNavigator
	-- with mode=StackPresentationStyle.Overlay. Your main app content goes inside
	-- a Page or navigator at this level. Note that to hide the automatic top bar
	-- for the root stack navigator, you have to set headerMode=StackHeaderMode.None.
	local config = Object.assign({
		mode = RoactNavigation.StackPresentationStyle.Overlay, -- use Overlay mode instead of Modal!
	}, navigatorOptions)
	local rootNavigator = RoactNavigation.createRobloxStackNavigator({
		{ MainContent = MainContent },
		{
			OverlayDialog = {
				screen = OverlayDialog,
				navigationOptions = {
					-- Draw an overlay effect under this page.
					-- You may use overlayColor3 to set a custom overlay color, and
					-- overlayTransparency to set a custom darkening amount if you
					-- need specific settings.
					overlayEnabled = true,
				},
			},
		},
	}, config)
	local appContainer = RoactNavigation.createAppContainer(rootNavigator)

	return setupReactStory(target, React.createElement(appContainer, { detached = true }))
end
