-- upstream https://github.com/react-navigation/react-navigation/blob/20e2625f351f90fadadbf98890270e43e744225b/packages/core/src/__tests__/getNavigation.test.js

return function()
	local RoactNavigationModule = script.Parent.Parent
	local getNavigation = require(RoactNavigationModule.getNavigation)
	local NavigationActions = require(RoactNavigationModule.NavigationActions)
	local Packages = RoactNavigationModule.Parent
	local JestGlobals = require(Packages.Dev.JestGlobals)
	local expect = JestGlobals.expect
	local jest = JestGlobals.jest

	it("getNavigation provides default action helpers", function()
		local router = {
			getActionCreators = function()
				return {}
			end,
			getStateForAction = function(_action, lastState)
				return lastState or {}
			end,
		}

		local dispatchSpy, dispatchSpyFn = jest.fn()

		local topNav = getNavigation(
			router,
			{},
			dispatchSpyFn,
			{},
			function()
				return {}
			end,
			function() end
		)

		topNav.navigate("GreatRoute")

		expect(dispatchSpy).toHaveBeenCalledTimes(1)
		expect(dispatchSpy.mock.calls[1][1].type).toBe(NavigationActions.Navigate)
		expect(dispatchSpy.mock.calls[1][1].routeName).toBe("GreatRoute")
	end)

	it("getNavigation provides router action helpers", function()
		local router = {
			getActionCreators = function()
				return {
					foo = function(bar)
						return { type = "FooBarAction", bar = bar }
					end,
				}
			end,
			getStateForAction = function(_action, lastState)
				return lastState or {}
			end,
		}

		local dispatchSpy, dispatchSpyFn = jest.fn()

		local topNav = nil
		topNav = getNavigation(
			router,
			{},
			dispatchSpyFn,
			{},
			function()
				return {}
			end,
			function()
				return topNav
			end
		)

		topNav.foo("Great")

		expect(dispatchSpy).toHaveBeenCalledTimes(1)
		expect(dispatchSpy.mock.calls[1][1].type).toBe("FooBarAction")
		expect(dispatchSpy.mock.calls[1][1].bar).toBe("Great")
	end)

	it("getNavigation get child navigation with router", function()
		local actionSubscribers = {}
		local navigation = nil

		local routerA = {
			getActionCreators = function()
				return {}
			end,
			getStateForAction = function(_action, lastState)
				return lastState or {}
			end,
		}
		local router = {
			childRouters = {
			RouteA = routerA,
			},
			getActionCreators = function()
				return {}
			end,
			getStateForAction = function(_action, lastState)
				return lastState or {}
			end,
		}

		local initState = {
			index = 0,
			routes = {
				{
					key = "a",
					routeName = "RouteA",
					routes = {{ key = "c", routeName = "RouteC" }},
					index = 0,
				},
				{ key = "b", routeName = "RouteB" },
			},
		}

		local topNav = getNavigation(
			router,
			initState,
			function() end,
			actionSubscribers,
			function()
				return {}
			end,
			function()
				return navigation
			end
		)

		local childNavA = topNav.getChildNavigation("a")

		expect(childNavA.router).toBe(routerA)
	end)
end
