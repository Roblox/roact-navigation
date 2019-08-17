local Roact = require(script.Parent.Parent.Parent.Roact)
local RoactNavigation = require(script.Parent.Parent.Parent.RoactNavigation)

--[[
	This story demonstrates how to build a screen component that uses the
	withNavigationFocus() helper to alter its UI when the page is focused
	or unfocused. We use a simple master-detail stack navigator as the basis:

	AppContainer
		StackNavigator
			MasterPage
			DetailPage
]]
return function(target)
	local MasterPage = Roact.Component:extend("MasterPage")

	function MasterPage:render()
		return RoactNavigation.withNavigationFocus(function(navigation, focused)
			return Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				Font = Enum.Font.Gotham,
				Text = "Master Page",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
			}, {
				detailButton = Roact.createElement("TextButton", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.new(1, 1, 1),
					Font = Enum.Font.Gotham,
					Position = UDim2.new(0.5, 0, 0.6, 0),
					Size = UDim2.new(0, 160, 0, 30),
					Text = "Go to Detail",
					TextColor3 = Color3.new(0, 0, 0),
					TextSize = 18,
					[Roact.Event.Activated] = function()
						-- Note that you can push() to force a new instance, instead!
						navigation.navigate("Detail")
					end
				})
			})
		end)
	end

	-- We can declare components functionally too!
	local function DetailPage(props)
		return RoactNavigation.withNavigationFocus(function(navigation, focused)
			return Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundColor3 = focused and Color3.new(255,0,0) or Color3.new(0,255,0),
			})
		end)
	end

	-- This is the top-level navigator. Note that child navigators are just Roact
	-- Components attached like any other route.
	local rootNavigator = RoactNavigation.createTopBarStackNavigator({
		routes = {
			Master = MasterPage,
			Detail = DetailPage,
		},
		initialRouteName = "Master",
	})

	local appContainer = RoactNavigation.createAppContainer(rootNavigator)
	local rootInstance = Roact.mount(Roact.createElement(appContainer), target)

	return function()
		Roact.unmount(rootInstance)
	end
end
