return function(target, linkingProtocolMock)
	local Storybook = script.Parent
	local Packages = Storybook.Parent

	local setupReactStory = require(Storybook.setupReactStory)
	local React = require(Packages.React)
	local RoactNavigation = require(Packages.RoactNavigation)

	local WHITE = Color3.fromRGB(255, 255, 255)
	local BLACK = Color3.fromRGB(0, 0, 0)

	local createLinkingProtocolMock = require(Storybook.createLinkingProtocolMock)

	if linkingProtocolMock == nil then
		linkingProtocolMock = createLinkingProtocolMock("login")
	end

	local function VerticalList(_props)
		return React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 8),
		})
	end

	local function Padding(props)
		return React.createElement("UIPadding", {
			PaddingBottom = UDim.new(0, props.amount),
			PaddingLeft = UDim.new(0, props.amount),
			PaddingRight = UDim.new(0, props.amount),
			PaddingTop = UDim.new(0, props.amount),
		})
	end

	local function Label(props)
		local onClick = props.onClick
		return React.createElement(if onClick then "TextButton" else "TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = BLACK,
			BackgroundTransparency = if onClick then 0.3 else 1,
			BorderSizePixel = 0,
			LineHeight = 1.5,
			Font = Enum.Font.RobotoMono,
			Text = props.text,
			TextSize = props.size or 15,
			TextColor3 = props.color or WHITE,
			TextWrapped = true,
			LayoutOrder = props.order,
			Size = UDim2.fromOffset(0, 0),
			TextXAlignment = props.align,
			[React.Event.Activated] = onClick,
		}, {
			Padding = React.createElement(Padding, {
				amount = 8,
			}),
			Children = props.children and React.createElement(React.Fragment, {}, props.children),
		})
	end

	local function Sheet(props)
		return React.createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BorderSizePixel = 0,
			BackgroundColor3 = props.color or BLACK,
			Size = UDim2.fromOffset(0, 0),
			BackgroundTransparency = props.transparency or 0.4,
			LayoutOrder = props.order,
		}, {
			Layout = React.createElement(VerticalList),
			Padding = React.createElement(Padding, {
				amount = 8,
			}),
			Children = props[React.Children] and React.createElement(React.Fragment, {}, props.children),
		})
	end

	local function NavigationPanel(props)
		return React.createElement(Sheet, {
			order = props.order,
		}, {
			Description = React.createElement(Label, {
				text = [[
Enter `profile/cranberry` to see cranberry's profile.
* The profile name is a URL parameter, so you can visit any profile you want.
Enter `profile/robot/settings` to view the settings screen.
Enter `profile/ketchup/friend/mustard` to see if they are friend.
Enter `login` to go back to the login screen.
]],
				align = Enum.TextXAlignment.Left,
				order = 1,
			}, {
				MaxSize = React.createElement("UISizeConstraint", {
					MaxSize = Vector2.new(400, math.huge),
				}),
			}),
			UpdateUrl = React.createElement(Sheet, {
				transparency = 0.7,
				order = 2,
			}, {
				EnterUrl = React.createElement(Label, {
					text = "Submit new URL event",
					order = 1,
				}),
				UrlBox = React.createElement("TextBox", {
					Text = "",
					BorderSizePixel = 0,
					PlaceholderText = "<enter url>",
					Size = UDim2.fromOffset(160, 32),
					TextColor3 = BLACK,
					PlaceholderColor3 = BLACK,
					LayoutOrder = 2,
					[React.Event.FocusLost] = function(textBox, enterPressed)
						if not enterPressed then
							return
						end
						local url = textBox.Text
						linkingProtocolMock.callback(url)
					end,
				}),
			}),
		})
	end

	local function Page(props)
		local navigation = props.navigation
		return React.createElement("Frame", {
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
		}, {
			Layout = React.createElement(VerticalList),
			PageLabel = React.createElement(Label, {
				text = props.title,
				color = BLACK,
				size = 18,
				order = 1,
			}),
			NavigatePanel = React.createElement(NavigationPanel, {
				order = 2,
			}),
			BackButton = navigation and React.createElement(Label, {
				text = "Go back",
				order = 3,
				onClick = function()
					navigation.goBack()
				end,
			}),
			Content = props.children and React.createElement("Frame", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BorderSizePixel = 0,
				BackgroundColor3 = BLACK,
				Size = UDim2.fromOffset(0, 0),
				BackgroundTransparency = 0.4,
				LayoutOrder = 4,
			}, props.children),
		})
	end

	local function LoginScreen(_props)
		return React.createElement(Page, {
			title = "Login screen",
		})
	end

	local function NoProfileScreen(props)
		local navigation = props.navigation
		return React.createElement(Page, {
			navigation = navigation,
			title = "No user is specified",
		})
	end

	local function ProfileScreen(props)
		local navigation = props.navigation
		local userName = navigation.getParam("name")
		return React.createElement(Page, {
			navigation = navigation,
			title = userName .. " Profile",
		}, {
			UserName = React.createElement(Label, {
				text = if userName then ("Current user: " .. userName) else "No user logged in",
			}),
		})
	end

	local function SettingsScreen(props)
		local navigation = props.navigation
		local userName = navigation.getParam("name")
		return React.createElement(Page, {
			navigation = navigation,
			title = userName .. "'s settings",
		}, {
			UserName = React.createElement(Label, {
				text = ":)",
			}),
		})
	end

	local function FriendScreen(props)
		local navigation = props.navigation
		local userName = navigation.getParam("name", "no one")
		local friendName = navigation.getParam("friend", "no one")

		return React.createElement(Page, {
			navigation = navigation,
			title = "Friend page",
		}, {
			UserName = React.createElement(Label, {
				text = ("%s is friend with %s"):format(userName, friendName),
			}),
		})
	end

	local userNavigator = RoactNavigation.createRobloxStackNavigator({
		{ noprofile = { screen = NoProfileScreen, path = "" } },
		{ profile = { screen = ProfileScreen, path = ":name" } },
		{ settings = { screen = SettingsScreen, path = ":name/settings" } },
		{ friend = { screen = FriendScreen, path = ":name/friend/:friend" } },
	})
	local rootNavigator = RoactNavigation.createSwitchNavigator({
		{ login = LoginScreen },
		{ user = { screen = userNavigator, path = "profile" } },
	})

	local appContainer = RoactNavigation.createAppContainer(
		rootNavigator,
		-- createAppContainer takes an optional second parameter to pass the
		-- LinkingProtocol interface (as defined within the lua-apps repo)
		linkingProtocolMock
	)

	return setupReactStory(target, React.createElement(appContainer, { detached = true }))
end
