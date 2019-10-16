local Roact = require(script.Parent.Parent.Parent.Roact)
local RoactNavigation = require(script.Parent.Parent.Parent.RoactNavigation)

--[[
	This story demonstrates how to build a StackNavigator-based UI with a top-level
	component that syncs to the transition animations.

	Frame
		Frame (will be animated)
		AppContainer
				StackNavigator
					MasterPage
					DetailPage
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
			Text = "Detail Page",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
		}, {
			goNextDetailButton = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.6, 0),
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
				Position = UDim2.new(0.5, 0, 0.6, 30),
				Size = UDim2.new(0, 160, 0, 30),
				Text = "Go back to Master",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					navigation.navigate("Master") -- jump all the way out!
				end,
			})
		})
	end

	local indicatorFrameRef = Roact.createRef()

	-- This is the top-level navigator. Note that child navigators are just Roact
	-- Components attached like any other route.
	local rootNavigator = RoactNavigation.createStackNavigator({
		routes = {
			Master = MasterPage,
			Detail = DetailPage,
		},
		initialRouteName = "Master",
		onTransitionStart = function(nextNavigation, prevNavigation)
			-- Monitor start of transition animations
			local nextRouteName = nextNavigation.state.routes[nextNavigation.state.index].routeName
			local prevRouteName = prevNavigation.state.routes[prevNavigation.state.index].routeName
			print("Start transition from ", prevRouteName, " to ", nextRouteName)

			if indicatorFrameRef.current then
				indicatorFrameRef.current.BackgroundColor3 = Color3.new(1, 0, 0)
			end
		end,
		onTransitionEnd = function(nextNavigation, prevNavigation)
			-- Monitor end of transition animations
			local nextRouteName = nextNavigation.state.routes[nextNavigation.state.index].routeName
			local prevRouteName = prevNavigation.state.routes[prevNavigation.state.index].routeName

			if indicatorFrameRef.current then
				indicatorFrameRef.current.BackgroundColor3 = Color3.new(0, 1, 0)
			end

			print("End transition from ", prevRouteName, " to ", nextRouteName)
		end,
		onTransitionStep = function(nextNavigation, prevNavigation, value)
			local nextRouteName = nextNavigation.state.routes[nextNavigation.state.index].routeName
			local prevRouteName = prevNavigation.state.routes[prevNavigation.state.index].routeName

			if indicatorFrameRef.current then
				indicatorFrameRef.current.BackgroundColor3 = Color3.new(1-value, value, 0)
			end

			print("Transition step from ", prevRouteName, " to ", nextRouteName, ": ", value)
		end
	})

	local appContainer = RoactNavigation.createAppContainer(rootNavigator)

	local rootFrame = Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
	}, {
		IndicatorFrame = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 50),
			BackgroundColor3 = Color3.new(1, 1, 1),
			ZIndex = 2,
			[Roact.Ref] = indicatorFrameRef,
		}),
		AppContainer = Roact.createElement(appContainer, {
			Position = UDim2.new(1, 0, 0, 50),
			Size = UDim2.new(1, 0, 1, -50),
			ZIndex = 1,
		}),
	})

	local rootInstance = Roact.mount(rootFrame, target)

	return function()
		Roact.unmount(rootInstance)
	end
end
