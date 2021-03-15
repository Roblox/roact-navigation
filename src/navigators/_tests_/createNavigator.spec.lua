return function()
	local navigatorsModule = script.Parent.Parent
	local RoactNavigationModule = navigatorsModule.Parent
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestRoblox).Globals.expect
	local Roact = require(Packages.Roact)

	local createNavigator = require(navigatorsModule.createNavigator)

	local testRouter = {
		getScreenOptions = function() return nil end,
	}

	it("should return a Roact component that exposes navigator fields", function()
		local testComponentMounted = nil
		local TestViewComponent = Roact.Component:extend("TestViewComponent")
		function TestViewComponent:render() end
		function TestViewComponent:didMount() testComponentMounted = true end
		function TestViewComponent:willUnmount() testComponentMounted = false end

		local testNavOptions = {}

		local navigator = createNavigator(TestViewComponent, testRouter, {
			navigationOptions = testNavOptions,
		})

		jestExpect(navigator.render).toEqual(jestExpect.any("function"))
		jestExpect(navigator.router).toBe(testRouter)
		jestExpect(navigator.navigationOptions).toBe(testNavOptions)

		local testNavigation = {
			state = {
				routes = {
					{ routeName = "Foo", key = "Foo" },
				},
				index = 1
			},
			getChildNavigation = function() return nil end, -- stub
			addListener = function() end,
		}

		-- Try to mount it
		local instance = Roact.mount(Roact.createElement(navigator, {
			navigation = testNavigation
		}))

		jestExpect(testComponentMounted).toEqual(true)
		Roact.unmount(instance)
		jestExpect(testComponentMounted).toEqual(false)
	end)

	it("should throw when trying to mount without navigation prop", function()
		local TestViewComponent = function() end

		local navigator = createNavigator(TestViewComponent, testRouter, {
			navigationOptions = {}
		})

		jestExpect(function()
			Roact.mount(Roact.createElement(navigator))
		end).toThrow()
	end)

	it("should throw when trying to mount without routes", function()
		local TestViewComponent = function() end

		local navigator = createNavigator(TestViewComponent, testRouter, {
			navigationOptions = {}
		})

		local testNavigation = {
			state = {
				index = 1
			},
			getChildNavigation = function() return nil end, -- stub
		}

		jestExpect(function()
			Roact.mount(Roact.createElement(navigator, {
				navigation = testNavigation
			}))
		end).toThrow()
	end)
end
