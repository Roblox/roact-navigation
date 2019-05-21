return function()
	local RoactNavigation = require(script.Parent)
	local Roact = require(script.Parent.Parent.Roact)

	it("should load", function()
		require(script.Parent)
	end)

	it("should return a function for createAppContainer", function()
		expect(type(RoactNavigation.createAppContainer)).to.equal("function")
	end)

	it("should return a function for getNavigation", function()
		expect(type(RoactNavigation.getNavigation)).to.equal("function")
	end)

	it("should return an appropriate table for NavigationContext", function()
		expect(type(RoactNavigation.NavigationContext)).to.equal("table")
		expect(type(RoactNavigation.NavigationContext.Provider)).to.equal("table")
		expect(type(RoactNavigation.NavigationContext.Consumer)).to.equal("table")
		expect(type(RoactNavigation.NavigationContext.connect)).to.equal("function")
	end)

	it("should return a table for NavigationProvider", function()
		expect(type(RoactNavigation.NavigationProvider)).to.equal("table")
	end)

	it("should return a table for NavigationConsumer", function()
		expect(type(RoactNavigation.NavigationConsumer)).to.equal("table")
	end)

	it("should return a function for connect", function()
		expect(type(RoactNavigation.connect)).to.equal("function")
	end)

	it("should return a function for withNavigation", function()
		expect(type(RoactNavigation.withNavigation)).to.equal("function")
	end)

	it("should return a valid component when calling createTopBarStackNavigator", function()
		local component = RoactNavigation.createTopBarStackNavigator()
		expect(component.render).never.to.equal(nil)

		local instance = Roact.mount(Roact.createElement(component))
		Roact.unmount(instance)
	end)

	it("should return a valid component when calling createBottomTabNavigator", function()
		local component = RoactNavigation.createBottomTabNavigator()
		expect(component.render).never.to.equal(nil)

		local instance = Roact.mount(Roact.createElement(component))
		Roact.unmount(instance)
	end)

	it("should return a function for StackRouter", function()
		expect(type(RoactNavigation.StackRouter)).to.equal("function")
	end)

	it("should return a function for SwitchRouter", function()
		expect(type(RoactNavigation.SwitchRouter)).to.equal("function")
	end)

	it("should return a function for TabRouter", function()
		expect(type(RoactNavigation.TabRouter)).to.equal("function")
	end)

	it("should return a table for Actions", function()
		expect(type(RoactNavigation.Actions)).to.equal("table")
	end)

	it("should return a table for StackActions", function()
		expect(type(RoactNavigation.StackActions)).to.equal("table")
	end)

	it("should return a table for Events", function()
		expect(type(RoactNavigation.Events)).to.equal("table")
	end)

	it("should return a valid component for EventsAdapter", function()
		expect(RoactNavigation.EventsAdapter.render).never.to.equal(nil)
		local instance = Roact.mount(Roact.createElement(RoactNavigation.EventsAdapter, {
			navigation = {}
		}))
		Roact.unmount(instance)
	end)

	it("should return a valid component for SceneView", function()
		expect(RoactNavigation.SceneView.render).never.to.equal(nil)
		local instance = Roact.mount(Roact.createElement(RoactNavigation.SceneView, {
			navigation = {},
			component = function() end,
		}))
		Roact.unmount(instance)
	end)

	it("should return a valid component for SwitchView", function()
		expect(RoactNavigation.SwitchView.render).never.to.equal(nil)

		local testNavigation = {
			state = {
				routes = {
					{ routeName = "Foo", key = "Foo", }
				},
				index = 1,
			}
		}

		local instance = Roact.mount(Roact.createElement(RoactNavigation.SwitchView, {
			descriptors = {
				Foo = {
					getComponent = function()
						return function() end
					end,
					navigation = testNavigation,
				}
			},
			navigation = testNavigation,
		}))
		Roact.unmount(instance)
	end)

	it("should return a function for createConfigGetter", function()
		expect(type(RoactNavigation.createConfigGetter)).to.equal("function")
	end)

	it("should return a function for getScreenForRouteName", function()
		expect(type(RoactNavigation.getScreenForRouteName)).to.equal("function")
	end)

	it("should return a function for validateRouteConfigMap", function()
		expect(type(RoactNavigation.validateRouteConfigMap)).to.equal("function")
	end)

	it("should return a function for getActiveChildNavigationOptions", function()
		expect(type(RoactNavigation.getActiveChildNavigationOptions)).to.equal("function")
	end)
end
