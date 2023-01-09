local Storybook = script.Parent.Parent
local Packages = Storybook.Parent

local setupReactStory = require(Storybook.setupReactStory)
local React = require(Packages.React)
local RoactNavigation = require(Packages.RoactNavigation)

--[[
	This story demonstrates how to build a basic StackNavigator-based UI. It creates
	the following hierarchy:

	AppContainer
		StackNavigator
			MasterPage
			DetailPage
]]
return function(target)
	local MasterPage = React.Component:extend("MasterPage")

	function MasterPage:render()
		local navigation = self.props.navigation

		return React.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Text = "Master Page",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
		}, {
			detailButton = React.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Size = UDim2.new(0, 160, 0, 30),
				Text = "Go to Detail",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[React.Event.Activated] = function()
					-- Note that you can push() to force a new instance, instead!
					navigation.navigate("Detail")
				end,
			}),
		})
	end

	-- We can declare components functionally too!
	local function DetailPage(props)
		local navigation = props.navigation
		local pushCount = navigation.getParam("pushCount", 0)

		return React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.Gotham,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0.5, 0, 0.5, 0),
			Text = "Detail Page #" .. pushCount,
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
		}, {
			goNextDetailButton = React.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Size = UDim2.new(0, 160, 0, 30),
				Text = "Push next detail",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[React.Event.Activated] = function()
					navigation.navigate({
						routeName = "Detail",
						key = ("Detail-%d"):format(pushCount + 1),
						params = { pushCount = pushCount + 1 },
					})
				end,
			}),
			goBackButton = React.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 30),
				Size = UDim2.new(0, 160, 0, 30),
				Text = "Go back to Master",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[React.Event.Activated] = function()
					navigation.navigate("Master") -- jump all the way out!
				end,
			}),
		})
	end

	-- This is the top-level navigator. Note that child navigators are just Roact
	-- Components attached like any other route.
	local rootNavigator = RoactNavigation.createRobloxStackNavigator({
		{ Master = MasterPage },
		{ Detail = DetailPage },
	})

	-- Navigators must all live under a single top-level container. The container
	-- provides the state tracking and action dispatching facilities that are the
	-- glue needed to make everything work. You can (probably) add additional app containers
	-- in sub-screens in order to create a completely different navigation hierarchy
	-- if you want to, but then they wouldn't integrate into the history management!
	local appContainer = RoactNavigation.createAppContainer(rootNavigator)

	-- The app container can be mounted at root level, or you can stick it inside
	-- any other Roact component if you need extra structure.

	return setupReactStory(target, React.createElement(appContainer, { detached = true }))
end
