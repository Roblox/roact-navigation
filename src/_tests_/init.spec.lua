return function()
	local RoactNavigationModule = script.Parent.Parent
	local RoactNavigation = require(RoactNavigationModule)
	local StackPresentationStyle = require(RoactNavigationModule.views.RobloxStackView.StackPresentationStyle)
	local Packages = RoactNavigationModule.Parent
	local Roact = require(Packages.Roact)
	local jestExpect = require(Packages.Dev.JestGlobals).expect

	it("should return a function for createAppContainer", function()
		jestExpect(RoactNavigation.createAppContainer).toEqual(jestExpect.any("function"))
	end)

	it("should return a function for getNavigation", function()
		jestExpect(RoactNavigation.getNavigation).toEqual(jestExpect.any("function"))
	end)

	it("should return an appropriate table for Context", function()
		jestExpect(RoactNavigation.Context).toEqual(jestExpect.any("table"))
		jestExpect(RoactNavigation.Context.Provider).toEqual(jestExpect.any("table"))
		jestExpect(RoactNavigation.Context.Consumer).toEqual(jestExpect.any("table"))
	end)

	it("should return a Component for Provider", function()
		jestExpect(RoactNavigation.Provider).toEqual(jestExpect.any("table"))
	end)

	it("should return a Component for Consumer", function()
		jestExpect(RoactNavigation.Consumer).toEqual(jestExpect.any("table"))
	end)

	it("should return a function for withNavigation", function()
		jestExpect(RoactNavigation.withNavigation).toEqual(jestExpect.any("function"))
	end)

	it("should return a function for withNavigationFocus", function()
		jestExpect(RoactNavigation.withNavigationFocus).toEqual(jestExpect.any("function"))
	end)

	it("should return a function for createRobloxSwitchNavigator", function()
		jestExpect(RoactNavigation.createRobloxSwitchNavigator).toEqual(jestExpect.any("function"))
	end)

	it("should return a function for createRobloxStackNavigator", function()
		jestExpect(RoactNavigation.createRobloxStackNavigator).toEqual(jestExpect.any("function"))
	end)

	it("should return a function for createSwitchNavigator", function()
		jestExpect(RoactNavigation.createSwitchNavigator).toEqual(jestExpect.any("function"))
	end)

	it("should return a function for createNavigator", function()
		jestExpect(RoactNavigation.createNavigator).toEqual(jestExpect.any("function"))
	end)

	it("should return a function for StackRouter", function()
		jestExpect(RoactNavigation.StackRouter).toEqual(jestExpect.any("function"))
	end)

	it("should return a function for SwitchRouter", function()
		jestExpect(RoactNavigation.SwitchRouter).toEqual(jestExpect.any("function"))
	end)

	it("should return a function for TabRouter", function()
		jestExpect(RoactNavigation.TabRouter).toEqual(jestExpect.any("function"))
	end)

	it("should return a table for Actions", function()
		jestExpect(RoactNavigation.Actions).toEqual(jestExpect.any("table"))
	end)

	it("should return a table for StackActions", function()
		jestExpect(RoactNavigation.StackActions).toEqual(jestExpect.any("table"))
	end)

	it("should return a table for SwitchActions", function()
		jestExpect(RoactNavigation.SwitchActions).toEqual(jestExpect.any("table"))
	end)

	it("should return a table for BackBehavior", function()
		jestExpect(RoactNavigation.BackBehavior).toEqual(jestExpect.any("table"))
	end)

	it("should return a table for Events", function()
		jestExpect(RoactNavigation.Events).toEqual(jestExpect.any("table"))
	end)

	it("should return a valid component for NavigationEvents", function()
		local instance = Roact.mount(Roact.createElement(RoactNavigation.Provider, {
			value = {
				addListener = function()
					return { remove = function() end }
				end,
			},
		}, {
			Events = Roact.createElement(RoactNavigation.NavigationEvents),
		}))
		Roact.unmount(instance)
	end)

	it("should return StackPresentationStyle", function()
		jestExpect(RoactNavigation.StackPresentationStyle).toBe(StackPresentationStyle)
	end)

	it("should return a valid component for SceneView", function()
		jestExpect(RoactNavigation.SceneView.render).toBeDefined()
		local instance = Roact.mount(Roact.createElement(RoactNavigation.SceneView, {
			navigation = {},
			component = function() end,
		}))
		Roact.unmount(instance)
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

		local instance = Roact.mount(Roact.createElement(RoactNavigation.RobloxSwitchView, {
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
		Roact.unmount(instance)
	end)

	it("should return a function for createConfigGetter", function()
		jestExpect(RoactNavigation.createConfigGetter).toEqual(jestExpect.any("function"))
	end)

	it("should return a function for getScreenForRouteName", function()
		jestExpect(RoactNavigation.getScreenForRouteName).toEqual(jestExpect.any("function"))
	end)

	it("should return a function for validateRouteConfigMap", function()
		jestExpect(RoactNavigation.validateRouteConfigMap).toEqual(jestExpect.any("function"))
	end)

	it("should return a function for getActiveChildNavigationOptions", function()
		jestExpect(RoactNavigation.getActiveChildNavigationOptions).toEqual(jestExpect.any("function"))
	end)
end
