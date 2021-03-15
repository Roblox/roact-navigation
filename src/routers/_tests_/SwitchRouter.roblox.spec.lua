return function()
	local routersModule = script.Parent.Parent
	local RoactNavigationModule = routersModule.Parent
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestRoblox).Globals.expect

	local NavigationActions = require(RoactNavigationModule.NavigationActions)
	local BackBehavior = require(RoactNavigationModule.BackBehavior)
	local SwitchRouter = require(routersModule.SwitchRouter)

	it("should be a function", function()
		jestExpect(SwitchRouter).toEqual(jestExpect.any("function"))
	end)

	it("should throw when passed a non-table", function()
		jestExpect(function()
			SwitchRouter(5)
		end).toThrow("routeConfigs must be an array table")
	end)

	it("should throw if initialRouteName is not found in routes table", function()
		jestExpect(function()
			SwitchRouter({
				{ Foo = function() end },
				{ Bar = function() end },
			}, {
				initialRouteName = "MyRoute",
			})
		end).toThrow("Invalid initialRouteName 'MyRoute'. Should be one of \"Foo\", \"Bar\"")
	end)

	it("should expose childRouters as a member", function()
		local router = SwitchRouter({
			{
				Foo = {
					screen = {
						render = function() end,
						router = "A",
					},
				},
			},
			{
				Bar = {
					screen = {
						render = function() end,
						router = "B",
					},
				},
			},
		})

		jestExpect(router.childRouters.Foo).toEqual("A")
		jestExpect(router.childRouters.Bar).toEqual("B")
	end)

	describe("getScreenOptions tests", function()
		it("should correctly configure default screen options", function()
			local router = SwitchRouter({
				{
					Foo = {
						screen = {
							render = function() end,
						}
					}
				},
			}, {
				defaultNavigationOptions = {
					title = "FooTitle",
				},
			})

			local screenOptions = router.getScreenOptions({
				state = {
					routeName = "Foo",
				}
			})

			jestExpect(screenOptions.title).toEqual("FooTitle")
		end)

		it("should correctly configure route-specified screen options", function()
			local router = SwitchRouter({
				{
					Foo = {
						screen = {
							render = function() end,
						},
						navigationOptions = { title = "RouteFooTitle" },
					}
				},
			}, {
				defaultNavigationOptions = {
					title = "FooTitle",
				},
			})

			local screenOptions = router.getScreenOptions({
				state = {
					routeName = "Foo",
				}
			})

			jestExpect(screenOptions.title).toEqual("RouteFooTitle")
		end)

		it("should correctly configure component-specified screen options", function()
			local router = SwitchRouter({
				{
					Foo = {
						screen = {
							render = function() end,
							navigationOptions = { title = "ComponentFooTitle" },
						},
					}
				},
			}, {
				defaultNavigationOptions = {
					title = "FooTitle",
				},
			})

			local screenOptions = router.getScreenOptions({
				state = {
					routeName = "Foo",
				}
			})

			jestExpect(screenOptions.title).toEqual("ComponentFooTitle")
		end)
	end)

	describe("getActionCreators tests", function()
		it("should return empty action creators table if none are provided", function()
			local router = SwitchRouter({
				{ Foo = { render = function() end } },
			})

			local actionCreators = router.getActionCreators({ routeName = "Foo" }, "key")

			local fieldCount = 0
			for _ in pairs(actionCreators) do
				fieldCount = fieldCount + 1
			end

			jestExpect(fieldCount).toEqual(0)
		end)

		it("should call custom action creators function if provided", function()
			local router = SwitchRouter({
				{ Foo = { render = function() end } },
			}, {
				getCustomActionCreators = function()
					return { a = 1 }
				end,
			})

			local actionCreators = router.getActionCreators({ routeName = "Foo" }, "key")
			jestExpect(actionCreators.a).toEqual(1)
		end)
	end)

	describe("getComponentForState tests", function()
		it("should return component matching requested state", function()
			local testComponent = function() end
			local router = SwitchRouter({
				{ Foo = { screen = testComponent } },
			})

			local component = router.getComponentForState({
				routes = {
					{ routeName = "Foo" },
				},
				index = 1,
			})
			jestExpect(component).toBe(testComponent)
		end)

		it("should throw if there is no route matching active index", function()
			local router = SwitchRouter({
				{ Foo = { screen = function() end } },
			})

			local message = "There is no route defined for index '2'. " ..
				"Check that you passed in a navigation state with a " ..
				"valid tab/screen index."
			jestExpect(function()
				router.getComponentForState({
					routes = {
						Foo = { screen = function() end },
					},
					index = 2,
				})
			end).toThrow(message)
		end)

		it("should descend child router for requested route", function()
			local testComponent = function() end
			local childRouter = SwitchRouter({
				{ Bar = { screen = testComponent } },
			})

			local router = SwitchRouter({
				{
					Foo = {
						screen = {
							render = function() end,
							router = childRouter,
						}
					},
				},
			})

			local component = router.getComponentForState({
				routes = {
					{
						routeName = "Foo",
						routes = { -- Child router's routes
							{ routeName = "Bar" },
						},
						index = 1
					},
				},
				index = 1,
			})
			jestExpect(component).toBe(testComponent)
		end)
	end)

	describe("getComponentForRouteName tests", function()
		it("should return a component that matches the given route name", function()
			local testComponent = function() end
			local router = SwitchRouter({
				{ Foo = { screen = testComponent } },
			})

			local component = router.getComponentForRouteName("Foo")
			jestExpect(component).toBe(testComponent)
		end)
	end)

	describe("getStateForAction tests", function()
		it("should return initial state for init action", function()
			local router =  SwitchRouter({
				{ Foo = { screen = function() end } },
				{ Bar = { screen = function() end } },
			})

			local state = router.getStateForAction(NavigationActions.init(), nil)
			jestExpect(#state.routes).toEqual(2)
			jestExpect(state.routes[state.index].routeName).toEqual("Foo")
		end)

		it("should adjust initial state index to match initialRouteName's index", function()
			local router =  SwitchRouter({
				{ Foo = { screen = function() end } },
				{ Bar = { screen = function() end } },
			})

			local state = router.getStateForAction(NavigationActions.init(), nil)
			jestExpect(state.routes[state.index].routeName).toEqual("Foo")

			local router2 =  SwitchRouter({
				{ Foo = { screen = function() end } },
				{ Bar = { screen = function() end } },
			}, {
				initialRouteName = "Bar",
			})

			local state2 = router2.getStateForAction(NavigationActions.init(), nil)
			jestExpect(state2.routes[state2.index].routeName).toEqual("Bar")
		end)

		it("should respect optional order property", function()
			local router =  SwitchRouter({
				{ Foo = { screen = function() end } },
				{ Bar = { screen = function() end } },
			})

			local state = router.getStateForAction(NavigationActions.init(), nil)
			jestExpect(state.routes[1].routeName).toEqual("Foo")
			jestExpect(state.routes[2].routeName).toEqual("Bar")
		end)

		it("should incorporate child router state", function()
			local childRouter = SwitchRouter({
				{ Bar = { screen = function() end } },
			})

			local router = SwitchRouter({
				{
					Foo = {
						render = function() end,
						router = childRouter,
					},
				},
				{ City = { screen = function() end } },
			})

			local state = router.getStateForAction(NavigationActions.init(), nil)
			local activeState = state.routes[state.index]
			jestExpect(activeState.routeName).toEqual("Foo") -- parent's tracking uses parent's route name
			jestExpect(activeState.routes[activeState.index].routeName).toEqual("Bar")
		end)

		it("should let active child handle non-init action first", function()
			local childRouter = SwitchRouter({
				{ Bar = { screen = function() end } },
				{ City = { screen = function() end } },
			})

			local router = SwitchRouter({
				{
					Foo = {
						render = function() end,
						router = childRouter,
					},
				},
				{ State = { render = function() end } },
			})

			local state = router.getStateForAction(NavigationActions.navigate({ routeName = "City" }))
			jestExpect(state.routes[1].index).toEqual(2)
			jestExpect(state.index).toEqual(1)
		end)

		it("should go back to initial route index if BackBehavior.InitialRoute", function()
			local router = SwitchRouter({
				{ Foo = { render = function() end } },
				{ Bar = { render = function() end } },
			}, {
				backBehavior = BackBehavior.InitialRoute,
			})

			local prevState = {
				routes = {
					{ routeName = "Foo" },
					{ routeName = "Bar" },
				},
				index = 2,
			}

			local newState = router.getStateForAction(NavigationActions.back(), prevState)
			jestExpect(newState.index).toEqual(1)
		end)

		it("should not change state on back action if BackBehavior.None", function()
			local router = SwitchRouter({
				{ Foo = { render = function() end } },
				{ Bar = { render = function() end } },
			})

			local prevState = {
				routes = {
					{ routeName = "Foo" },
					{ routeName = "Bar" },
				},
				index = 2,
			}

			local newState = router.getStateForAction(NavigationActions.back(), prevState)
			jestExpect(newState).toBe(prevState)
		end)

		it("should change active route on navigate", function()
			local router = SwitchRouter({
				{ Foo = { render = function() end } },
				{ Bar = { render = function() end } },
			})

			local newState = router.getStateForAction(NavigationActions.navigate({ routeName = "Bar" }))
			jestExpect(newState.index).toEqual(2)
			jestExpect(newState.routes[newState.index].routeName).toEqual("Bar")
		end)

		it("should pass sub-action to child router on navigate", function()
			local childRouter = SwitchRouter({
				{ City = { screen = function() end } },
				{ State = { screen = function() end } },
			})

			local router = SwitchRouter({
				{ Foo = { render = function() end } },
				{ Bar = {
						render = function() end,
						router = childRouter,
					},
				},
			})

			local newState = router.getStateForAction(NavigationActions.navigate({
				routeName = "Bar",
				action = NavigationActions.navigate({ routeName = "State" }),
			}))

			local activeRoute = newState.routes[newState.index]
			jestExpect(activeRoute.routeName).toEqual("Bar")
			jestExpect(activeRoute.routes[activeRoute.index].routeName).toEqual("State")
		end)

		it("should return initial state if navigating to active child without previous state", function()
			local childRouter = SwitchRouter({
				{ Bar = { screen = function() end } },
			})

			local router = SwitchRouter({
				{
					Foo = {
						render = function() end,
						router = childRouter,
					},
				},
				{ City = { render = function() end } },
			})

			local newState = router.getStateForAction(NavigationActions.navigate({
				routeName = "Foo",
			}))

			jestExpect(newState.routes[newState.index].routeName).toEqual("Foo")
		end)

		it("should reset state for deactivated route by default", function()
			local router = SwitchRouter({
				{ Foo = { render = function() end } },
				{ Bar = { render = function() end } },
			})

			local initialState = {
				routes = {
					{ routeName = "Foo", params = { a = 1 } },
					{ routeName = "Bar" },
				},
				index = 1,
			}

			local state = router.getStateForAction(NavigationActions.navigate({ routeName = "Bar" }), initialState)
			jestExpect(state.routes[1].params).toEqual(nil) -- should be empty
		end)

		it("should not reset state for deactivated route if resetOnBlur is false", function()
			local router = SwitchRouter({
				{ Foo = { render = function() end } },
				{ Bar = { render = function() end } },
			}, {
				resetOnBlur = false,
			})

			local testParams = { a = 1 }

			local initialState = {
				routes = {
					{ routeName = "Foo", params = testParams },
					{ routeName = "Bar" },
				},
				index = 1,
			}

			local state = router.getStateForAction(NavigationActions.navigate({ routeName = "Bar" }), initialState)
			jestExpect(state.routes[1].params).toEqual(testParams)
		end)

		it("should set params on route for setParams action", function()
			local router = SwitchRouter({
				{ Foo = { render = function() end } },
				{ Bar = { render = function() end } },
			})

			local newState = router.getStateForAction(NavigationActions.setParams({
				key = "Foo", -- By default, key == routeName
				params = { a = 1 },
			}))

			jestExpect(newState.routes[newState.index].params.a).toEqual(1)
		end)

		it("should preserve route configured params for child router", function()
			local childRouter = SwitchRouter({
				{
					Bar = {
						screen = function() end,
						params = { a = 2 },
					},
				},
			})

			local router = SwitchRouter({
				{
					Foo = {
						render = function() end,
						params = { a = 1 },
						router = childRouter,
					},
				},
				{ City = { render = function() end } },
			})

			local state = router.getStateForAction(NavigationActions.init())
			jestExpect(state.routes[state.index].params.a).toEqual(1)
		end)

		it("should merge initialRouteParams with initial route's own params", function()
			local router = SwitchRouter({
				{
					Foo = {
						render = function() end,
						params = { a = 1 },
					},
				},
				{
					Bar = {
						render = function() end,
						params = { a = 1 },
					},
				},
			}, {
				initialRouteParams = { a = 2, b = 3 },
			})

			local state = router.getStateForAction(NavigationActions.init())
			jestExpect(state.routes[1].params.a).toEqual(2)
			jestExpect(state.routes[1].params.b).toEqual(3)
			jestExpect(state.routes[2].params.a).toEqual(1)
			jestExpect(state.routes[2].params.b).toEqual(nil)
		end)

		it("should merge init action params with initial route's own params and initialRouteParams", function()
			local router = SwitchRouter({
				{
					Foo = { render = function() end, params = { a = 1 } }
				},
			}, {
				initialRouteParams = { c = 3 },
			})

			local state = router.getStateForAction(NavigationActions.init({ params = { b = 2 } }))
			jestExpect(state.routes[1].params.a).toEqual(1)
			jestExpect(state.routes[1].params.b).toEqual(2)
			jestExpect(state.routes[1].params.c).toEqual(3)
		end)

		it("should merge navigate action params for child router", function()
			local childRouter = SwitchRouter({
				{
					Bar = {
						screen = function() end,
						params = { a = 2 },
					},
				},
			})

			local router = SwitchRouter({
				{
					Foo = {
						render = function() end,
						router = childRouter,
					},
				},
			})

			local state = router.getStateForAction(NavigationActions.navigate({
				routeName = "Bar",
				params = { b = 3 },
			}))

			jestExpect(state.routes[1].routes[1].params.a).toEqual(2)
			jestExpect(state.routes[1].routes[1].params.b).toEqual(3)
		end)

		it("should propagate a child router getStateForAction failure to caller", function()
			local childRouter = SwitchRouter({
				{ Bar = { screen = function() end } },
			})

			local router = SwitchRouter({
				{
					Foo = {
						render = function() end,
						router = childRouter,
					},
				},
			})

			-- need to properly initialize state because we're being abusive of getStateForAction
			local initialState = router.getStateForAction(NavigationActions.init())

			childRouter.getStateForAction = function() return nil end

			local state = router.getStateForAction(NavigationActions.navigate("Bar"), initialState)
			jestExpect(state).toEqual(nil)
		end)
	end)
end

