return function()
	local RoactNavigationModule = script.Parent.Parent
	local Packages = RoactNavigationModule.Parent
	local Roact = require(Packages.Roact)
	local jestExpect = require(Packages.Dev.JestRoblox).Globals.expect
	local NavigationActions = require(RoactNavigationModule.NavigationActions)
	local createAppContainerExports = require(RoactNavigationModule.createAppContainer)
	local createAppContainer = createAppContainerExports.createAppContainer
	local _TESTING_ONLY_reset_container_count = createAppContainerExports._TESTING_ONLY_reset_container_count
	local createSwitchNavigator = require(RoactNavigationModule.navigators.createSwitchNavigator)

	beforeEach(function()
		_TESTING_ONLY_reset_container_count()
	end)

	it("should be a function", function()
		jestExpect(createAppContainer).toEqual(jestExpect.any("function"))
	end)

	it("should return a valid component when mounting a switch navigator", function()
		local TestNavigator = createSwitchNavigator({
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
		local TestNavigator = createSwitchNavigator({
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

		local TestNavigator = createSwitchNavigator({
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

	describe("with deep linking", function()
		local function getLinkingProtocolMock(initialURL)
			local linkingProtocolMock = {}

			function linkingProtocolMock:listenForLuaURLs(callback, sticky)
				self.callback = callback
				self.sticky = sticky
			end

			function linkingProtocolMock:getLastLuaURL()
				return initialURL
			end

			function linkingProtocolMock:stopListeningForLuaURLs()
				self.callback = nil
			end

			return linkingProtocolMock
		end

		local function findFirstDescendantOfClass(parent, className)
			for _, descendant in ipairs(parent:GetDescendants()) do
				if descendant:IsA(className) then
					return descendant
				end
			end
			return nil
		end

		-- use a class that we will never find within the instance hierarchy created
		-- by Roact Navigation. That way if the swith navigation implementation changes,
		-- we won't have to modify the test
		local UNIQUE_CLASS_NAME = "HopperBin"

		it("connects and disconnects from `listenForLuaURLs`", function()
			local function Screen(_props)
				return nil
			end
			local testNavigator = createSwitchNavigator({
				{ Foo = { screen = Screen, path = "foo" } },
				{ Bar = { screen = Screen, path = "bar" } },
			})

			local protocolMock = getLinkingProtocolMock("foo")
			local app = createAppContainer(testNavigator, protocolMock)

			local element = Roact.createElement(app)
			local tree = Roact.mount(element)

			jestExpect(protocolMock.callback).never.toEqual(nil)
			jestExpect(protocolMock.sticky).toEqual(false)

			Roact.unmount(tree)

			jestExpect(protocolMock.callback).toEqual(nil)
		end)

		it("uses the last URL to set the initial navigation state", function()
			local fooElementClass = "TextLabel"
			local barElementClass = "Frame"
			local function FooScreen(_props)
				return Roact.createElement(UNIQUE_CLASS_NAME, {}, {
					Foo = Roact.createElement(fooElementClass),
				})
			end
			local function BarScreen(_props)
				return Roact.createElement(UNIQUE_CLASS_NAME, {}, {
					Bar = Roact.createElement(barElementClass)
				})
			end

			for url, expectedClass in pairs({
				foo = {fooElementClass, barElementClass},
				bar = {barElementClass, fooElementClass},
			}) do
				local testNavigator = createSwitchNavigator({
					{ Foo = { screen = FooScreen, path = "foo" } },
					{ Bar = { screen = BarScreen, path = "bar" } },
				})

				local protocolMock = getLinkingProtocolMock(url)
				local app = createAppContainer(testNavigator, protocolMock)

				local element = Roact.createElement(app)
				local parent = Instance.new("Folder")
				local tree = Roact.mount(element, parent)

				local screen = findFirstDescendantOfClass(parent, UNIQUE_CLASS_NAME)
				jestExpect(screen).toBeDefined()
				jestExpect(screen:FindFirstChildOfClass(expectedClass[1])).toBeDefined()
				jestExpect(screen:FindFirstChildOfClass(expectedClass[2])).toBeUndefined()

				Roact.unmount(tree)
			end
		end)

		it("can get the params from the initial URL", function()
			local fooElementClass = "TextLabel"
			local barElementClass = "Frame"
			local function FooScreen(_props)
				return Roact.createElement(UNIQUE_CLASS_NAME, {}, {
					Foo = Roact.createElement(fooElementClass),
				})
			end
			local function BarScreen(props)
				local navigation = props.navigation
				local name = navigation.getParam("name")
				return Roact.createElement(UNIQUE_CLASS_NAME, {}, {
					[name] = Roact.createElement(barElementClass, {
						Name = name,
					})
				})
			end

			local testNavigator = createSwitchNavigator({
				{ Foo = { screen = FooScreen, path = "foo" } },
				{ Bar = { screen = BarScreen, path = "bar/:name" } },
			})

			local expectName = "orange"
			local protocolMock = getLinkingProtocolMock("bar/" .. expectName)
			local app = createAppContainer(testNavigator, protocolMock)

			local element = Roact.createElement(app)
			local parent = Instance.new("Folder")
			local tree = Roact.mount(element, parent)

			local screen = findFirstDescendantOfClass(parent, UNIQUE_CLASS_NAME)
			jestExpect(screen).toBeDefined()
			local barInstance = screen:FindFirstChildOfClass(barElementClass)
			jestExpect(barInstance).toBeDefined()
			jestExpect(barInstance.Name).toEqual(expectName)
			jestExpect(screen:FindFirstChildOfClass(fooElementClass)).toBeUndefined()

			Roact.unmount(tree)
		end)

		it("updates the navigation state when the URL updates", function()
			local fooElementClass = "TextLabel"
			local barElementClass = "Frame"
			local function FooScreen(_props)
				return Roact.createElement(UNIQUE_CLASS_NAME, {}, {
					Foo = Roact.createElement(fooElementClass),
				})
			end
			local function BarScreen(_props)
				return Roact.createElement(UNIQUE_CLASS_NAME, {}, {
					Bar = Roact.createElement(barElementClass)
				})
			end

			local testNavigator = createSwitchNavigator({
				{ Foo = { screen = FooScreen, path = "foo" } },
				{ Bar = { screen = BarScreen, path = "bar" } },
			})

			local protocolMock = getLinkingProtocolMock("foo")
			local app = createAppContainer(testNavigator, protocolMock)

			local element = Roact.createElement(app)
			local parent = Instance.new("Folder")
			local tree = Roact.mount(element, parent)

			local screen = findFirstDescendantOfClass(parent, UNIQUE_CLASS_NAME)
			jestExpect(screen).toBeDefined()
			jestExpect(screen:FindFirstChildOfClass(fooElementClass)).toBeDefined()
			jestExpect(screen:FindFirstChildOfClass(barElementClass)).toBeUndefined()

			protocolMock.callback("bar")

			screen = findFirstDescendantOfClass(parent, UNIQUE_CLASS_NAME)
			jestExpect(screen).toBeDefined()
			jestExpect(screen:FindFirstChildOfClass(barElementClass)).toBeDefined()
			jestExpect(screen:FindFirstChildOfClass(fooElementClass)).toBeUndefined()

			Roact.unmount(tree)
		end)
	end)
end
