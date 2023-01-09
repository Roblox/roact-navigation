local Storybook = script.Parent.Parent
local Packages = Storybook.Parent

local setupReactStory = require(Storybook.setupReactStory)
local React = require(Packages.React)
local RoactNavigation = require(Packages.RoactNavigation)

--[[
	This story demonstrates how to declare properties that will be passed to
	your screens at diferent times.

	screenProps - A table that is passed globally from top-level. Use this for
		declarative (static) data, which you can access via props.screenProps.
		ScreenProps are not encoded into the navigation state since they (presumably)
		do not change unless the top-level component manipulates them.
	params - A table that may be specified with a number of navigation actions to
		dynamically adjust the contents of your screens, e.g. a game UUID when
		showing a details subpage. Params are encoded into the navigation state.
]]
return function(target)
	local function MyPage(props)
		local screenProps = props.screenProps
		local navigation = props.navigation
		local primaryTitle = screenProps.primaryTitle or "None"
		local extraTitle = navigation.getParam("extraTitle", "None")
		local text = string.format("%s: %s", primaryTitle, extraTitle)

		return React.createElement("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.Gotham,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0.5, 0, 0.25, 0),
			Text = text,
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
			[React.Event.Activated] = function()
				navigation.navigate("MyPage", {
					extraTitle = "It's updated!",
				})
			end,
		})
	end

	local navigator = RoactNavigation.createRobloxSwitchNavigator({
		{ MyPage = MyPage },
	}, {
		initialRouteParams = {
			extraTitle = "Tap to Update",
		},
	})

	local appContainer = RoactNavigation.createAppContainer(navigator)

	local element = React.createElement(appContainer, {
		detached = true,
		screenProps = {
			primaryTitle = "Primary",
		},
	})

	return setupReactStory(target, element)
end
