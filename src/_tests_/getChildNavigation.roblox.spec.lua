return function()
	local RoactNavigationModule = script.Parent.Parent
	local getChildNavigation = require(RoactNavigationModule.getChildNavigation)
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestGlobals).expect

	it("should return nil if there is no route matching requested key", function()
		local testNavigation = {
			state = {
				routes = {
					{ key = "a" }
				}
			}
		}

		local childNav = getChildNavigation(testNavigation, "invalid_child", function()
			return testNavigation
		end)

		jestExpect(childNav).toEqual(nil)
	end)

	it("should return cached child if its state is a top-level route", function()
		local testNavigation = {
			state = {
				routes = {
					{ key = "a" }
				},

			},
		}

		testNavigation._childrenNavigation = {
			a = {
				state  = testNavigation.state.routes[1]
			}
		}

		local childNav = getChildNavigation(testNavigation, "a", function()
			return testNavigation
		end)

		jestExpect(childNav).toBe(testNavigation._childrenNavigation.a)
	end)

	it("should update cache and return new data when child's state has changed", function()
		local testNavigation = {
			state = {
				routes = {
					{ key = "a", routeName = "a" },
					{ key = "b", routeName = "b" },
				},
				index = 1,
			},
			router = {
				getComponentForRouteName = function(_routeName)
					return function() end
				end,
				getActionCreators = function() end,
			},
		}

		local oldStateA = {
			isFirstRouteInParent = function()
				return true
			end,
			state  = {
				routes = {
					{ key = "a", routeName = "a" },
					{ key = "b", routeName = "b" },
				},
				index = 2,
			},
		}

		testNavigation._childrenNavigation = {
			a = oldStateA,
		}

		local childNav = getChildNavigation(testNavigation, "a", function()
			return testNavigation
		end)

		jestExpect(childNav).toBe(testNavigation._childrenNavigation["a"])
		jestExpect(childNav.state).toBe(testNavigation.state.routes[1])
		jestExpect(childNav.getParam).toEqual(jestExpect.any("function"))
	end)

	it("should create a new entry if cached child does not exist yet", function()
		local testNavigation = {
			state = {
				routes = {
					{ key = "a", routeName = "a", params = { a = 1 } },
					{ key = "b", routeName = "b" },
				},
				index = 1,
			},
			router = {
				getComponentForRouteName = function(_routeName)
					return function() end
				end,
				getActionCreators = function() end,
			},
			addListener = function()
				return {
					remove = function() end
				}
			end,
			isFocused = function()
				return true
			end,
		} :: any

		local childNav = getChildNavigation(testNavigation, "a", function()
			return testNavigation
		end)

		jestExpect(testNavigation._childrenNavigation["a"]).never.toEqual(nil)
		jestExpect(childNav).toEqual(testNavigation._childrenNavigation["a"])
		jestExpect(childNav.isFocused()).toEqual(true)

		jestExpect(childNav.getParam("a", 0)).toEqual(1)
		jestExpect(childNav.getParam("b", 0)).toEqual(0)
	end)
end
