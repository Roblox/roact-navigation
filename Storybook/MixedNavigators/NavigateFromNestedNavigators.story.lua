local Storybook = script.Parent.Parent
local Packages = Storybook.Parent

local setupReactStory = require(Storybook.setupReactStory)
local React = require(Packages.React)
local RoactNavigation = require(Packages.RoactNavigation)

--[[
	AppContainer
		StackNavigator
			MainContent = StackNavigator
			    Initial
				Pages = SwitchNavigator
					PageA
					PageB
			Other = StackNavigator
				PageOne
				PageTwo
]]
return function(target)
	local BUTTON_HEIGHT = 30

	local function Button(props)
		return React.createElement("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.Gotham,
			Position = props.Position,
			Size = UDim2.new(0, 200, 0, BUTTON_HEIGHT),
			Text = props.Text,
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
			[React.Event.Activated] = props.Click,
		})
	end

	local function Label(props)
		return React.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Text = props.Text,
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
		}, props[React.Children])
	end

	local function Initial(props)
		local navigation = props.navigation

		return React.createElement(Label, {
			Text = "Main App Initial Page",
		}, {
			showMainPageB = React.createElement(Button, {
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Text = "Go to pages",
				Click = function()
					navigation.navigate("Pages")
				end,
			}),
			showPageOne = React.createElement(Button, {
				Position = UDim2.new(0.5, 0, 0.6, BUTTON_HEIGHT),
				Text = "Open on Page One",
				Click = function()
					navigation.navigate("PageOne")
				end,
			}),
			showPageTwo = React.createElement(Button, {
				Position = UDim2.new(0.5, 0, 0.6, 2 * BUTTON_HEIGHT),
				Text = "Open on Page Two",
				Click = function()
					navigation.navigate("PageTwo")
				end,
			}),
		})
	end

	local function PageA(props)
		local navigation = props.navigation

		return React.createElement(Label, {
			Text = "Main App Page A",
		}, {
			showMainPageB = React.createElement(Button, {
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Text = "Go to page B",
				Click = function()
					navigation.navigate("PageB")
				end,
			}),
			showPageOne = React.createElement(Button, {
				Position = UDim2.new(0.5, 0, 0.6, BUTTON_HEIGHT),
				Text = "Open on Page One",
				Click = function()
					navigation.navigate("PageOne")
				end,
			}),
			showPageTwo = React.createElement(Button, {
				Position = UDim2.new(0.5, 0, 0.6, 2 * BUTTON_HEIGHT),
				Text = "Open on Page Two",
				Click = function()
					navigation.navigate("PageTwo")
				end,
			}),
		})
	end

	local function PageB(props)
		local navigation = props.navigation

		return React.createElement(Label, {
			Text = "Main App Page B",
		}, {
			goToInitial = React.createElement(Button, {
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Text = "Go to Initial Page",
				Click = function()
					navigation.navigate("Initial")
				end,
			}),
			showPageOne = React.createElement(Button, {
				Position = UDim2.new(0.5, 0, 0.6, BUTTON_HEIGHT),
				Text = "Open on Page One",
				Click = function()
					navigation.navigate("PageOne")
				end,
			}),
			showPageTwo = React.createElement(Button, {
				Position = UDim2.new(0.5, 0, 0.6, 2 * BUTTON_HEIGHT),
				Text = "Open on Page Two",
				Click = function()
					navigation.navigate("PageTwo")
				end,
			}),
		})
	end

	local function PageOne(props)
		local navigation = props.navigation

		return React.createElement(Label, {
			Text = "Page 1",
		}, {
			showModalButton = React.createElement(Button, {
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Text = "Go to Page 2",
				Click = function()
					navigation.navigate("PageTwo")
				end,
			}),
		})
	end

	local function PageTwo(props)
		local navigation = props.navigation

		return React.createElement(Label, {
			Text = "Page 2",
		}, {
			dismissButton = React.createElement(Button, {
				Position = UDim2.new(0.5, 0, 0.6, 0),
				Text = "Dismiss Modal Dialog",
				Click = function()
					-- Dismiss pops this entire inner stack by directing a Back action to
					-- the parent navigator.
					navigation.dismiss()
				end,
			}),
		})
	end

	local Pages = RoactNavigation.createRobloxSwitchNavigator({
		{ PageA = PageA },
		{ PageB = PageB },
	})

	local MainContent = RoactNavigation.createRobloxSwitchNavigator({
		{ Initial = Initial },
		{ Pages = Pages },
	})

	local ModalNavigator = RoactNavigation.createRobloxStackNavigator({
		{ PageOne = PageOne },
		{ PageTwo = PageTwo },
	})

	local rootNavigator = RoactNavigation.createRobloxStackNavigator({
		{ MainContent = MainContent },
		{ ModalDialog = ModalNavigator },
	})
	local appContainer = RoactNavigation.createAppContainer(rootNavigator)

	return setupReactStory(target, React.createElement(appContainer, { detached = true }))
end
