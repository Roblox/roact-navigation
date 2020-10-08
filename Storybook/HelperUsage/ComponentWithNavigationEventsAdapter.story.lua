local Roact = require(script.Parent.Parent.Parent.Roact)
local RoactNavigation = require(script.Parent.Parent.Parent.RoactNavigation)

--[[
	This story demonstrates how to build a screen component that listens
	to navigation events using RoactNavigation.NavigationEvents. It makes a
	basic master-detail stack navigator to exercise the events.
]]
return function(target)
	local MasterPage = Roact.Component:extend("MasterPage")

	function MasterPage:init()
		self._onWillFocus = function()
			print("MasterPage: willFocus")
			self:setState({
				bgColor = Color3.new(1, 0, 0),
			})
		end

		self._onWillBlur = function()
			print("MasterPage: willBlur")
			self:setState({
				bgColor = Color3.new(0, 0, 1),
			})
		end

		self._onDidFocus = function()
			print("MasterPage: didFocus")
			self:setState({
				bgColor = Color3.new(0, 1, 0),
			})
		end

		self._onDidBlur = function()
			print("MasterPage: didBlur")
			self:setState({
				bgColor = Color3.new(0, 0, 0),
			})
		end

		self.state = {
			bgColor = Color3.new(1, 1, 1),
		}
	end

	function MasterPage:didMount()
		print("MasterPage: didMount")
	end

	function MasterPage:willUnmount()
		print("MasterPage: willUnmount")
	end

	function MasterPage:render()
		local navigation = self.props.navigation
		local bgColor = self.state.bgColor

		return Roact.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = bgColor,
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Text = "Master Page",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 18,
		}, {
			eventsAdapter = Roact.createElement(RoactNavigation.NavigationEvents, {
				onWillFocus = self._onWillFocus,
				onDidFocus = self._onDidFocus,
				onWillBlur = self._onWillBlur,
				onDidBlur = self._onDidBlur,
			}),
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
			}),
		})
	end

	local DetailPage = Roact.Component:extend("DetailPage")

	function DetailPage:init()
		self._onWillFocus = function()
			print("DetailPage: willFocus")
			self:setState({
				bgColor = Color3.new(1, 0, 0),
			})
		end

		self._onWillBlur = function()
			print("DetailPage: willBlur")
			self:setState({
				bgColor = Color3.new(0, 0, 1),
			})
		end

		self._onDidFocus = function()
			print("DetailPage: didFocus")
			self:setState({
				bgColor = Color3.new(0, 1, 0),
			})
		end

		self._onDidBlur = function()
			print("DetailPage: didBlur")
			self:setState({
				bgColor = Color3.new(0, 0, 0),
			})
		end

		self.state = {
			bgColor = Color3.new(0, 0, 0),
		}
	end

	function DetailPage:didMount()
		print("DetailPage: didMount")
	end

	function DetailPage:willUnmount()
		print("DetailPage: willUnmount")
	end

	function DetailPage:render(props)
		local bgColor = self.state.bgColor
		local navigation = self.props.navigation

		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = bgColor,
		}, {
			eventsAdapter = Roact.createElement(RoactNavigation.NavigationEvents, {
				onWillFocus = self._onWillFocus,
				onDidFocus = self._onDidFocus,
				onWillBlur = self._onWillBlur,
				onDidBlur = self._onDidBlur,
			}),
			backButton = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Size = UDim2.new(0, 160, 0, 30),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Text = "Go Back",
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					navigation.goBack()
				end
			})
		})
	end

	-- This is the top-level navigator. Note that child navigators are just Roact
	-- Components attached like any other route.
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
