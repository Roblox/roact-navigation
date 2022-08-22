local Roact = require(script.Parent.Parent.Parent.Roact)
local RoactNavigation = require(script.Parent.Parent.Parent.RoactNavigation)

--[[
	This story demonstrates how to build a navigator where one of the pages
	embeds another navigator within its component tree.

	AppContainer:
		StackNavigator:
			Master
			Detail
				<SwitchNavigator as inner Component>
					SubDetailA
					SubDetailB
]]
return function(target)
	local function SubPageA(props)
		local navigation = props.navigation
		return Roact.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Text = "Sub Page A",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
		}, {
			detailButton = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Size = UDim2.new(0, 200, 0, 30),
				Text = "Switch to Sub Page B",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					navigation.navigate("SubDetailB")
				end,
			}),
			goToMasterButton = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 30),
				Size = UDim2.new(0, 200, 0, 30),
				Text = "Go to Master",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					-- Since we're in an embedded switch navigator, goBack() won't take us up the chain!
					navigation.navigate("Master")
				end,
			}),
		})
	end

	local function SubPageB(props)
		local navigation = props.navigation
		return Roact.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Text = "Sub Page B",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
		}, {
			detailButton = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Size = UDim2.new(0, 200, 0, 30),
				Text = "Switch to Sub Page A",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					navigation.navigate("SubDetailA")
				end,
			}),
			goToMasterButton = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 30),
				Size = UDim2.new(0, 200, 0, 30),
				Text = "Go to Master",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					-- Since we're in an embedded switch navigator, goBack() won't take us up the chain!
					navigation.navigate("Master")
				end,
			}),
		})
	end

	local InnerSwitchNavigator = RoactNavigation.createRobloxSwitchNavigator({
		{ SubDetailA = SubPageA },
		{ SubDetailB = SubPageB },
	})

	local DetailPage = Roact.Component:extend("DetailPage")

	-- When creating a navigator that draws within a sub-area of another screen,
	-- you must manually pass the router up so the navigation system can be
	-- aware of it, and you also need to pass down the navigation prop.
	DetailPage.router = InnerSwitchNavigator.router

	function DetailPage:render()
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(0, 0, 0),
		}, {
			wrapperFrame = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0.75, 0, 0.75, 0),
				BackgroundColor3 = Color3.fromRGB(100, 100, 100),
			}, {
				innerNavigator = Roact.createElement(InnerSwitchNavigator, {
					navigation = self.props.navigation,
				}),
			}),
			backButton = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0, 10, 0, 0),
				Size = UDim2.new(0, 100, 0.1, 0),
				Text = "Back",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					self.props.navigation.goBack()
				end,
			}),
			goToMasterButton = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(1, -10, 0, 0),
				Size = UDim2.new(0, 150, 0.1, 0),
				Text = "Go to Master",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					self.props.navigation.navigate("Master")
				end,
			}),
		})
	end

	local function MasterPage(props)
		local navigation = props.navigation
		local value = navigation.getParam("value", 0)
		return Roact.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Text = "Master Page: " .. value,
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
		}, {
			masterButton = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Size = UDim2.new(0, 160, 0, 30),
				Text = "Go to Master",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					navigation.navigate("Master", { value = value + 1 })
				end,
			}),
			detailButton = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 30),
				Size = UDim2.new(0, 160, 0, 30),
				Text = "Go to Detail",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					navigation.navigate("Detail")
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
