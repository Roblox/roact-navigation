return function()
	local RoactNavigationModule = script.Parent.Parent
	local RoactNavigation = require(RoactNavigationModule)
	local StackPresentationStyle = require(RoactNavigationModule.views.RobloxStackView.StackPresentationStyle)
	local Packages = RoactNavigationModule.Parent
	local React = require(Packages.React)
	local ReactRoblox = require(Packages.Dev.ReactRoblox)
	local expect = require(Packages.Dev.JestGlobals).expect

	it("should return a function for createAppContainer", function()
		expect(RoactNavigation.createAppContainer).toEqual(expect.any("function"))
	end)

	it("should return a function for getNavigation", function()
		expect(RoactNavigation.getNavigation).toEqual(expect.any("function"))
	end)

	it("should return an appropriate table for Context", function()
		expect(RoactNavigation.Context).toEqual(expect.any("table"))
		expect(RoactNavigation.Context.Provider).toEqual(expect.any("table"))
		expect(RoactNavigation.Context.Consumer).toEqual(expect.any("table"))
	end)

	it("should return a Component for Provider", function()
		expect(RoactNavigation.Provider).toEqual(expect.any("table"))
	end)

	it("should return a Component for Consumer", function()
		expect(RoactNavigation.Consumer).toEqual(expect.any("table"))
	end)

	it("should return a function for withNavigation", function()
		expect(RoactNavigation.withNavigation).toEqual(expect.any("function"))
	end)

	it("should return a function for withNavigationFocus", function()
		expect(RoactNavigation.withNavigationFocus).toEqual(expect.any("function"))
	end)

	it("should return a function for createRobloxSwitchNavigator", function()
		expect(RoactNavigation.createRobloxSwitchNavigator).toEqual(expect.any("function"))
	end)

	it("should return a function for createRobloxStackNavigator", function()
		expect(RoactNavigation.createRobloxStackNavigator).toEqual(expect.any("function"))
	end)

	it("should return a function for createSwitchNavigator", function()
		expect(RoactNavigation.createSwitchNavigator).toEqual(expect.any("function"))
	end)

	it("should return a function for createNavigator", function()
		expect(RoactNavigation.createNavigator).toEqual(expect.any("function"))
	end)

	it("should return a function for StackRouter", function()
		expect(RoactNavigation.StackRouter).toEqual(expect.any("function"))
	end)

	it("should return a function for SwitchRouter", function()
		expect(RoactNavigation.SwitchRouter).toEqual(expect.any("function"))
	end)

	it("should return a function for TabRouter", function()
		expect(RoactNavigation.TabRouter).toEqual(expect.any("function"))
	end)

	it("should return a table for Actions", function()
		expect(RoactNavigation.Actions).toEqual(expect.any("table"))
	end)

	it("should return a table for StackActions", function()
		expect(RoactNavigation.StackActions).toEqual(expect.any("table"))
	end)

	it("should return a table for SwitchActions", function()
		expect(RoactNavigation.SwitchActions).toEqual(expect.any("table"))
	end)

	it("should return a table for BackBehavior", function()
		expect(RoactNavigation.BackBehavior).toEqual(expect.any("table"))
	end)

	it("should return a table for Events", function()
		expect(RoactNavigation.Events).toEqual(expect.any("table"))
	end)

	it("should return a valid component for NavigationEvents", function()
		local parent = Instance.new("Folder")
		local reactRoot = ReactRoblox.createRoot(parent)

		ReactRoblox.act(function()
			reactRoot:render(React.createElement(RoactNavigation.Provider, {
				value = {
					addListener = function()
						return { remove = function() end }
					end,
				},
			}, {
				Events = React.createElement(RoactNavigation.NavigationEvents),
			}))
		end)
		ReactRoblox.act(function()
			reactRoot:unmount()
		end)
	end)

	it("should return StackPresentationStyle", function()
		expect(RoactNavigation.StackPresentationStyle).toBe(StackPresentationStyle)
	end)

	it("should return a valid component for SceneView", function()
		expect(RoactNavigation.SceneView.render).toBeDefined()
		local parent = Instance.new("Folder")
		local reactRoot = ReactRoblox.createRoot(parent)

		ReactRoblox.act(function()
			reactRoot:render(React.createElement(RoactNavigation.SceneView, {
				navigation = {},
				component = function() end,
			}))
		end)
		ReactRoblox.act(function()
			reactRoot:unmount()
		end)
	end)

	it("should return a valid component for RobloxSwitchView", function()
		local testNavigation = {
			state = {
				routes = {
					{ routeName = "Foo", key = "Foo" },
				},
				index = 1,
			},
		}

		local parent = Instance.new("Folder")
		local reactRoot = ReactRoblox.createRoot(parent)

		ReactRoblox.act(function()
			reactRoot:render(React.createElement(RoactNavigation.RobloxSwitchView, {
				descriptors = {
					Foo = {
						getComponent = function()
							return function() end
						end,
						navigation = testNavigation,
					},
				},
				navigation = testNavigation,
			}))
		end)
		ReactRoblox.act(function()
			reactRoot:unmount()
		end)
	end)

	it("should return a function for createConfigGetter", function()
		expect(RoactNavigation.createConfigGetter).toEqual(expect.any("function"))
	end)

	it("should return a function for getScreenForRouteName", function()
		expect(RoactNavigation.getScreenForRouteName).toEqual(expect.any("function"))
	end)

	it("should return a function for validateRouteConfigMap", function()
		expect(RoactNavigation.validateRouteConfigMap).toEqual(expect.any("function"))
	end)

	it("should return a function for getActiveChildNavigationOptions", function()
		expect(RoactNavigation.getActiveChildNavigationOptions).toEqual(expect.any("function"))
	end)
end
