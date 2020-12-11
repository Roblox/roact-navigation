return function()
	local Roact = require(script.Parent.Parent.Parent.Roact)
	local NavigationActions = require(script.Parent.Parent.NavigationActions)
	local createAppContainer = require(script.Parent.Parent.createAppContainer)
	local createRobloxSwitchNavigator = require(script.Parent.Parent.navigators.createRobloxSwitchNavigator)

	it("should be a function", function()
		expect(createAppContainer).to.be.a("function")
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

		expect(function()
			Roact.mount(element)
		end).to.throw("This navigator has both navigation and container props, " ..
			"so it is unclear if it should own its own state")
	end)

	it("should throw when not passed a table for AppComponent", function()
		local TestAppComponent = 5

		expect(function()
			createAppContainer(TestAppComponent)
		end).to.throw("AppComponent must be a navigator or a stateful Roact " ..
			"component with a 'router' field")
	end)

	it("should throw when passed a stateful component without router field", function()
		local TestAppComponent = Roact.Component:extend("TestAppComponent")

		expect(function()
			createAppContainer(TestAppComponent)
		end).to.throw("AppComponent must be a navigator or a stateful Roact " ..
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
		expect(type(registeredCallback)).to.equal("function")

		-- Make sure it processes action
		local result = registeredCallback(NavigationActions.navigate({
			routeName = "Foo",
		}))
		expect(result).to.equal(true)

		local failResult = registeredCallback(NavigationActions.navigate({
			routeName = "Bar", -- should fail because not a valid route
		}))
		expect(failResult).to.equal(false)

		Roact.unmount(instance)
		expect(registeredCallback).to.equal(nil)
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

		expect(passedScreenProps).to.equal(testScreenProps)
		expect(extractedValue1).to.equal("MyValue1")
		expect(extractedMissingValue1).to.equal(5)
		expect(extractedMissingValue2).to.equal(nil)

		Roact.unmount(instance)
	end)
end

