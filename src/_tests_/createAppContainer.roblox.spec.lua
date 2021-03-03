return function()
	local RoactNavigationModule = script.Parent.Parent
	local Packages = RoactNavigationModule.Parent
	local Roact = require(Packages.Roact)
	local jestExpect = require(Packages.Dev.JestRoblox).Globals.expect
	local NavigationActions = require(RoactNavigationModule.NavigationActions)
	local createAppContainer = require(RoactNavigationModule.createAppContainer)
	local createRobloxSwitchNavigator = require(RoactNavigationModule.navigators.createRobloxSwitchNavigator)

	it("should be a function", function()
		jestExpect(createAppContainer).toEqual(jestExpect.any("function"))
	end)

	it("should return a valid component when mounting a switch navigator", function()
		local TestNavigator = createRobloxSwitchNavigator({
			{ Foo = function() end },
		})

		local TestApp = createAppContainer(TestNavigator)
		local element = Roact.createElement(TestApp)
		local instance = Roact.mount(element)

		Roact.unmount(instance)
	end)

	it("should throw when navigator has both navigation and container props", function()
		local TestAppComponent = Roact.Component:extend("TestAppComponent")
		TestAppComponent.router = {}
		function TestAppComponent:render() end

		local element = Roact.createElement(createAppContainer(TestAppComponent), {
			navigation = {},
			somePropThatShouldNotBeHere = true,
		})

		jestExpect(function()
			Roact.mount(element)
		end).toThrow("This navigator has both navigation and container props, " ..
			"so it is unclear if it should own its own state")
	end)

	it("should throw when not passed a table for AppComponent", function()
		local TestAppComponent = 5

		jestExpect(function()
			createAppContainer(TestAppComponent)
		end).toThrow("AppComponent must be a navigator or a stateful Roact " ..
			"component with a 'router' field")
	end)

	it("should throw when passed a stateful component without router field", function()
		local TestAppComponent = Roact.Component:extend("TestAppComponent")

		jestExpect(function()
			createAppContainer(TestAppComponent)
		end).toThrow("AppComponent must be a navigator or a stateful Roact " ..
			"component with a 'router' field")
	end)

	it("should accept actions from externalDispatchConnector", function()
		local TestNavigator = createRobloxSwitchNavigator({
			{ Foo = function() end },
		})

		local registeredCallback = nil
		local externalDispatchConnector = function(rnCallback)
			registeredCallback = rnCallback
			return function()
				registeredCallback = nil
			end
		end

		local element = Roact.createElement(createAppContainer(TestNavigator), {
			externalDispatchConnector = externalDispatchConnector,
		})

		local instance = Roact.mount(element)
		jestExpect(registeredCallback).toEqual(jestExpect.any("function"))

		-- Make sure it processes action
		local result = registeredCallback(NavigationActions.navigate({
			routeName = "Foo",
		}))
		jestExpect(result).toEqual(true)

		local failResult = registeredCallback(NavigationActions.navigate({
			routeName = "Bar", -- should fail because not a valid route
		}))
		jestExpect(failResult).toEqual(false)

		Roact.unmount(instance)
		jestExpect(registeredCallback).toEqual(nil)
	end)

	it("should correctly pass screenProps to pages", function()
		local passedScreenProps = nil
		local extractedValue1 = nil
		local extractedMissingValue1 = nil
		local extractedMissingValue2 = nil

		local testScreenProps = {
			MyKey1 = "MyValue1",
		}

		local TestNavigator = createRobloxSwitchNavigator({
			{
				Foo = function(props)
					-- doing this in render is an abuse, but it's just a test
					passedScreenProps = props.navigation.getScreenProps()
					extractedValue1 = props.navigation.getScreenProps("MyKey1")
					extractedMissingValue1 = props.navigation.getScreenProps("MyMissingKey", 5)
					extractedMissingValue2 = props.navigation.getScreenProps("MyMissingKey")
				end,
			},
		})

		local TestApp = createAppContainer(TestNavigator)
		local element = Roact.createElement(TestApp, {
			screenProps = testScreenProps,
		})
		local instance = Roact.mount(element)

		jestExpect(passedScreenProps).toEqual(testScreenProps)
		jestExpect(extractedValue1).toEqual("MyValue1")
		jestExpect(extractedMissingValue1).toEqual(5)
		jestExpect(extractedMissingValue2).toEqual(nil)

		Roact.unmount(instance)
	end)
end

