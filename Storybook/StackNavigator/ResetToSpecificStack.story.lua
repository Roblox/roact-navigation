local Roact = require(script.Parent.Parent.Parent.Roact)
local RoactNavigation = require(script.Parent.Parent.Parent.RoactNavigation)

--[[
	This story demonstrates how to manually reset a StackNavigator to a specific
	route. This is useful for deep-links or performing more complex navigation
	where we want to drill down to a specific subpage.
]]
return function(target)
	local MasterPage = Roact.Component:extend("MasterPage")

	function MasterPage:render()
		local navigation = self.props.navigation

		return Roact.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Text = "Master Page",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
		}, {
			resetToDetail2Button = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Size = UDim2.new(0, 160, 0, 30),
				Text = "Reset to Detail (2)",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					navigation.reset({
						RoactNavigation.Actions.navigate({
							routeName = "Master",
						}),
						RoactNavigation.StackActions.push({
							routeName = "Detail",
						}),
						RoactNavigation.StackActions.push({
							routeName = "Detail",
							params = {
								pushCount = 1,
							},
						}),
						RoactNavigation.StackActions.push({
							routeName = "Detail",
							params = {
								pushCount = 2,
							},
						}),
					})
				end,
			}),
		})
	end

	-- We can declare components functionally too!
	local function DetailPage(props)
		local navigation = props.navigation
		local pushCount = navigation.getParam("pushCount", 0)

		return Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.Gotham,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0.5, 0, 0.5, 0),
			Text = "Detail Page #" .. pushCount,
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
		}, {
			resetToDetail2Button = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Size = UDim2.new(0, 160, 0, 30),
				Text = "Reset to Detail (2)",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					navigation.reset({
						RoactNavigation.Actions.navigate({
							routeName = "Master",
						}),
						RoactNavigation.StackActions.push({
							routeName = "Detail",
						}),
						RoactNavigation.StackActions.push({
							routeName = "Detail",
							params = {
								pushCount = 1,
							},
						}),
						RoactNavigation.StackActions.push({
							routeName = "Detail",
							params = {
								pushCount = 2,
							},
						}),
					})
				end,
			}),
			goNextDetailButton = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 30),
				Size = UDim2.new(0, 160, 0, 30),
				Text = "Push next detail",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					navigation.push("Detail", { pushCount = pushCount + 1 })
				end,
			}),
			goBackButton = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 60),
				Size = UDim2.new(0, 160, 0, 30),
				Text = "Go back",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					navigation.goBack()
				end,
			}),
		})
	end

	local rootNavigator = RoactNavigation.createRobloxStackNavigator({
		{ Master = MasterPage },
		{ Detail = DetailPage },
	})

	local appContainer = RoactNavigation.createAppContainer(rootNavigator)
	local rootInstance = Roact.mount(Roact.createElement(appContainer), target)

	return function()
		Roact.unmount(rootInstance)
	end
end
