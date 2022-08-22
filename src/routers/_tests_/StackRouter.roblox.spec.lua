return function()
	local routersModule = script.Parent.Parent
	local RoactNavigationModule = routersModule.Parent
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestGlobals).expect

	local StackRouter = require(routersModule.StackRouter)
	local StackActions = require(routersModule.StackActions)
	local NavigationActions = require(RoactNavigationModule.NavigationActions)

	it("should be a function", function()
		jestExpect(StackRouter).toEqual(jestExpect.any("function"))
	end)

	it("should throw when passed a non-table", function()
		jestExpect(function()
			StackRouter(5)
		end).toThrow("routeConfigs must be an array table")
	end)

	it("should throw if initialRouteName is not found in routes table", function()
		jestExpect(function()
			StackRouter({
				{ Foo = function() end },
				{ Bar = function() end },
			}, {
				initialRouteName = "MyRoute",
			})
		end).toThrow("Invalid initialRouteName 'MyRoute'. Must be one of [Foo,Bar,]")
	end)

	it("should expose childRouters as a member", function()
		local router = StackRouter({
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

	it("should not expose childRouters list members if they are CHILD_IS_SCREEN", function()
		local router = StackRouter({
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
					},
				},
			},
		})

		jestExpect(router.childRouters.Foo).toEqual("A")

		jestExpect(router._CHILD_IS_SCREEN).never.toEqual(nil)
		for _, childRouter in pairs(router.childRouters) do
			jestExpect(childRouter).never.toBe(router._CHILD_IS_SCREEN)
		end
	end)

	describe("getScreenOptions tests", function()
		it("should correctly configure default screen options", function()
			local router = StackRouter({
				{
					Foo = {
						screen = {
							render = function() end,
						},
					},
				},
			}, {
				defaultNavigationOptions = {
					title = "FooTitle",
				},
			})

			local screenOptions = router.getScreenOptions({
				state = {
					routeName = "Foo",
				},
			})

			jestExpect(screenOptions.title).toEqual("FooTitle")
		end)

		it("should correctly configure route-specified screen options", function()
			local router = StackRouter({
				{
					Foo = {
						screen = {
							render = function() end,
						},
						navigationOptions = { title = "RouteFooTitle" },
					},
				},
			}, {
				defaultNavigationOptions = {
					title = "FooTitle",
				},
			})

			local screenOptions = router.getScreenOptions({
				state = {
					routeName = "Foo",
				},
			})

			jestExpect(screenOptions.title).toEqual("RouteFooTitle")
		end)

		it("should correctly configure component-specified screen options", function()
			local router = StackRouter({
				{
					Foo = {
						screen = {
							render = function() end,
							navigationOptions = { title = "ComponentFooTitle" },
						},
					},
				},
			}, {
				defaultNavigationOptions = {
					title = "FooTitle",
				},
			})

			local screenOptions = router.getScreenOptions({
				state = {
					routeName = "Foo",
				},
			})

			jestExpect(screenOptions.title).toEqual("ComponentFooTitle")
		end)
	end)

	describe("getActionCreators tests", function()
		it("should return basic action creators table if none are provided", function()
			local router = StackRouter({
				{
					Foo = { render = function() end },
				},
			})

			local actionCreators = router.getActionCreators({ routeName = "Foo" }, "key")

			local fieldCount = 0
			for _ in pairs(actionCreators) do
				fieldCount = fieldCount + 1
			end

			jestExpect(fieldCount).toEqual(6)
			jestExpect(actionCreators.pop).toEqual(jestExpect.any("function"))
			jestExpect(actionCreators.popToTop).toEqual(jestExpect.any("function"))
			jestExpect(actionCreators.push).toEqual(jestExpect.any("function"))
			jestExpect(actionCreators.replace).toEqual(jestExpect.any("function"))
			jestExpect(actionCreators.reset).toEqual(jestExpect.any("function"))
			jestExpect(actionCreators.dismiss).toEqual(jestExpect.any("function"))
		end)

		it("should call custom action creators function if provided", function()
			local router = StackRouter({
				{
					Foo = { render = function() end },
				},
			}, {
				getCustomActionCreators = function()
					return { a = 1, popToTop = 2 }
				end,
			})

			local actionCreators = router.getActionCreators({ routeName = "Foo" }, "key")
			jestExpect(actionCreators.a).toEqual(1)

			-- make sure that we merged the default ones on top!
			jestExpect(actionCreators.pop).toEqual(jestExpect.any("function"))
			jestExpect(actionCreators.popToTop).toEqual(jestExpect.any("function"))
		end)

		it("should build a pop action", function()
			local router = StackRouter({
				{ Foo = function() end },
			})

			local actionCreators = router.getActionCreators({ routeName = "Foo" }, "key")
			jestExpect(actionCreators.pop(1).type).toBe(StackActions.Pop)
		end)

		it("should build a pop to top action", function()
			local router = StackRouter({
				{ Foo = function() end },
			})

			local actionCreators = router.getActionCreators({ routeName = "Foo" }, "key")
			jestExpect(actionCreators.popToTop().type).toBe(StackActions.PopToTop)
		end)

		it("should build a push action", function()
			local router = StackRouter({
				{ Foo = function() end },
			})

			local actionCreators = router.getActionCreators({ routeName = "Foo" }, "key")
			jestExpect(actionCreators.push("Foo").type).toBe(StackActions.Push)
		end)

		it("should build a replace action with a string replaceWith arg", function()
			local router = StackRouter({
				{ Foo = function() end },
			})

			local actionCreators = router.getActionCreators({ routeName = "Foo", key = "Foo" }, "key")
			jestExpect(actionCreators.replace("Foo").type).toBe(StackActions.Replace)
		end)

		it("should build a replace action with a table replaceWith arg", function()
			local router = StackRouter({
				{ Foo = function() end },
			})

			local actionCreators = router.getActionCreators({ routeName = "Foo" }, "key")
			jestExpect(actionCreators.replace({ routeName = "Foo" }).type).toBe(StackActions.Replace)
		end)

		it("should build a reset action", function()
			local router = StackRouter({
				{ Foo = function() end },
			})

			local actionCreators = router.getActionCreators({ routeName = "Foo" }, "key")
			jestExpect(actionCreators.reset({
				actions = { NavigationActions.navigate({ routeName = "Foo" }) },
			}).type).toBe(StackActions.Reset)
		end)

		it("should build a dismiss action", function()
			local router = StackRouter({
				{ Foo = function() end },
			})

			local actionCreators = router.getActionCreators({ routeName = "Foo" }, "key")
			jestExpect(actionCreators.dismiss().type).toBe(NavigationActions.Back)
		end)
	end)

	describe("getComponentForState tests", function()
		it("should throw if there is no route matching active index", function()
			local router = StackRouter({
				{ Foo = { screen = function() end } },
			})

			local message = "There is no route defined for index '2'. "
				.. "Make sure that you passed in a navigation state with a "
				.. "valid stack index."
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
			local childRouter = StackRouter({
				{ Bar = { screen = testComponent } },
			})

			local router = StackRouter({
				{
					Foo = {
						screen = {
							render = function() end,
							router = childRouter,
						},
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
						index = 1,
					},
				},
				index = 1,
			})
			jestExpect(component).toBe(testComponent)
		end)
	end)

	describe("getComponentForRouteName tests", function()
		it("should return a component that matches the given route name from accessed childRouter", function()
			local testComponent = function() end
			local childRouter = StackRouter({
				{ Bar = testComponent },
			})

			local router = StackRouter({
				{
					Foo = {
						render = function() end,
						router = childRouter,
					},
				},
			})

			local component = router.childRouters.Foo.getComponentForRouteName("Bar")
			jestExpect(component).toBe(testComponent)
		end)
	end)

	describe("getStateForAction tests", function()
		it("should return initial state for init action", function()
			local router = StackRouter({
				{ Foo = { screen = function() end } },
				{ Bar = { screen = function() end } },
			})

			local state = router.getStateForAction(NavigationActions.init(), nil)
			jestExpect(#state.routes).toEqual(1)
			jestExpect(state.routes[state.index].routeName).toEqual("Foo")
			jestExpect(state.isTransitioning).toEqual(false)
		end)

		it("should adjust initial state index to match initialRouteName's index", function()
			local router = StackRouter({
				{ Foo = { screen = function() end } },
				{ Bar = { screen = function() end } },
			})

			local state = router.getStateForAction(NavigationActions.init(), nil)
			jestExpect(state.routes[state.index].routeName).toEqual("Foo")

			local router2 = StackRouter({
				{ Foo = { screen = function() end } },
				{ Bar = { screen = function() end } },
			}, {
				initialRouteName = "Bar",
			})

			local state2 = router2.getStateForAction(NavigationActions.init(), nil)
			jestExpect(state2.routes[state2.index].routeName).toEqual("Bar")
		end)

		it("should incorporate child router state", function()
			local childRouter = StackRouter({
				{ Bar = { screen = function() end } },
			})

			local router = StackRouter({
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

		it("should make historical inactive child router active if it handles action", function()
			local childRouter = StackRouter({
				{ City = function() end },
				{ State = function() end },
			})

			local router = StackRouter({
				{ Foo = function() end },
				{
					Bar = {
						render = function() end,
						router = childRouter,
					},
				},
			})

			local initialState = {
				routes = {
					{ routeName = "Foo", key = "Foo1" },
					{
						routeName = "Bar",
						key = "Bar",
						routes = {
							{ routeName = "City", key = "City" },
						},
						index = 1,
					},
					{ routeName = "Foo", key = "Foo2" },
				},
				index = 3,
			}

			local resultState =
				router.getStateForAction(NavigationActions.navigate({ routeName = "State" }), initialState)
			jestExpect(resultState.routes[2].index).toEqual(2)
			jestExpect(resultState.routes[2].routes[2].routeName).toEqual("State")
			jestExpect(#resultState.routes[2].routes).toEqual(2)
			jestExpect(resultState.index).toEqual(2)
		end)

		it("should go back to previous stack entry on back action", function()
			local router = StackRouter({
				{ Foo = function() end },
				{ Bar = function() end },
			})

			local initialState = {
				key = "root",
				routes = {
					{
						routeName = "Foo",
						key = "Foo",
					},
					{
						routeName = "Bar",
						key = "Bar",
					},
				},
				index = 2,
			}

			local resultState = router.getStateForAction(NavigationActions.back(), initialState)
			jestExpect(resultState.index).toEqual(1)
			jestExpect(resultState.routes[1].routeName).toEqual("Foo")
			jestExpect(#resultState.routes).toEqual(1) -- it should delete top entry!
		end)

		it("should not go back if at root of stack", function()
			local router = StackRouter({
				{ Foo = function() end },
				{ Bar = function() end },
			})

			local initialState = {
				key = "root",
				routes = {
					{
						routeName = "Foo",
						key = "Foo",
					},
				},
				index = 1,
			}

			local resultState = router.getStateForAction(NavigationActions.back(), initialState)
			jestExpect(resultState).toBe(initialState)
		end)

		it("should go back out of child stack if on root of child", function()
			local childRouter = StackRouter({
				{ Bar = { screen = function() end } },
				{ City = { screen = function() end } },
			})

			local router = StackRouter({
				{
					Foo = {
						render = function() end,
						router = childRouter,
					},
				},
				{ Cat = function() end },
			}, {
				initialRouteName = "Cat",
			})

			local initialState = {
				key = "root",
				routes = {
					{
						routeName = "Cat",
						key = "Cat",
					},
					{
						routeName = "Foo",
						key = "Foo",
						routes = {
							{
								routeName = "Bar",
								key = "Bar",
							},
						},
						index = 1,
					},
				},
				index = 2,
			}

			local resultState = router.getStateForAction(NavigationActions.back(), initialState)
			jestExpect(resultState.index).toEqual(1)
			jestExpect(#resultState.routes).toEqual(1)
			jestExpect(resultState.routes[1].routeName).toEqual("Cat")
		end)

		it("should go back within active child if not on root of child", function()
			local childRouter = StackRouter({
				{ Bar = { screen = function() end } },
				{ City = { screen = function() end } },
			})

			local router = StackRouter({
				{
					Foo = {
						render = function() end,
						router = childRouter,
					},
				},
				{ Cat = function() end },
			}, {
				initialRouteName = "Cat",
			})

			local initialState = {
				key = "root",
				routes = {
					{
						routeName = "Cat",
						key = "Cat",
					},
					{
						routeName = "Foo",
						key = "Foo",
						routes = {
							{
								routeName = "Bar",
								key = "Bar",
							},
							{
								routeName = "City",
								key = "City",
							},
						},
						index = 2,
					},
				},
				index = 2,
			}

			local resultState = router.getStateForAction(NavigationActions.back(), initialState)
			jestExpect(#resultState.routes).toEqual(2)
			jestExpect(resultState.index).toEqual(2)
			jestExpect(resultState.routes[1].routeName).toEqual("Cat")
			jestExpect(resultState.routes[2].routeName).toEqual("Foo")

			jestExpect(#resultState.routes[2].routes).toEqual(1)
			jestExpect(resultState.routes[2].index).toEqual(1)
			jestExpect(resultState.routes[2].routes[1].routeName).toEqual("Bar")
		end)

		it("should pop to top", function()
			local router = StackRouter({
				{ Foo = function() end },
				{ Bar = function() end },
			})

			local initialState = {
				key = "root",
				routes = {
					{
						routeName = "Foo",
						key = "Foo",
					},
					{
						routeName = "Bar",
						key = "Bar1",
					},
					{
						routeName = "Bar",
						key = "Bar2",
					},
				},
				index = 3,
			}

			local resultState = router.getStateForAction(StackActions.popToTop(), initialState)
			jestExpect(#resultState.routes).toEqual(1)
			jestExpect(resultState.index).toEqual(1)
			jestExpect(resultState.routes[1].routeName).toEqual("Foo")
		end)

		it("should pop to top through child router", function()
			local childRouter = StackRouter({
				{ Bar = function() end },
				{ City = function() end },
			})

			local router = StackRouter({
				{
					Foo = {
						screen = function() end,
						router = childRouter,
					},
				},
				{ Crazy = function() end },
			}, {
				initialRouteName = "Crazy",
			})

			local initialState = {
				key = "root",
				routes = {
					{
						routeName = "Crazy",
						key = "Crazy",
					},
					{
						routeName = "Foo",
						key = "Foo",
						routes = {
							{
								routeName = "Bar",
								key = "Bar",
							},
							{
								routeName = "City",
								key = "City",
							},
						},
						index = 2,
					},
				},
				index = 2,
			}

			local resultState = router.getStateForAction(StackActions.popToTop(), initialState)
			jestExpect(#resultState.routes).toEqual(1)
			jestExpect(resultState.index).toEqual(1)
			jestExpect(resultState.routes[1].routeName).toEqual("Crazy")
		end)

		it("should push a new entry on navigate without instance of that screen", function()
			local router = StackRouter({
				{ Foo = function() end },
				{ Bar = function() end },
			})

			local initialState = {
				key = "root",
				routes = {
					{
						routeName = "Foo",
						key = "Foo",
					},
				},
				index = 1,
			}

			local resultState =
				router.getStateForAction(NavigationActions.navigate({ routeName = "Bar" }), initialState)
			jestExpect(#resultState.routes).toEqual(2)
			jestExpect(resultState.index).toEqual(2)
			jestExpect(resultState.routes[2].routeName).toEqual("Bar")
		end)

		it("should jump to existing entry in stack if one exists already, on navigate", function()
			local router = StackRouter({
				{ Foo = function() end },
				{ Bar = function() end },
				{ City = function() end },
			})

			local initialState = {
				key = "root",
				routes = {
					{
						routeName = "Foo",
						key = "Foo",
					},
					{
						routeName = "Bar",
						key = "Bar",
					},
					{
						routeName = "City",
						key = "City",
					},
				},
				index = 3,
			}

			local resultState = router.getStateForAction(
				NavigationActions.navigate({
					routeName = "Bar",
					params = { a = 1 },
				}),
				initialState
			)
			jestExpect(#resultState.routes).toEqual(2)
			jestExpect(resultState.index).toEqual(2)
			jestExpect(resultState.routes[2].routeName).toEqual("Bar")
			jestExpect(resultState.routes[2].params.a).toEqual(1)
		end)

		it("should jump to existing entry in stack if one exists already, on navigate, with empty params", function()
			local router = StackRouter({
				{ Foo = function() end },
				{ Bar = function() end },
				{ City = function() end },
			})

			local initialState = {
				key = "root",
				routes = {
					{
						routeName = "Foo",
						key = "Foo",
					},
					{
						routeName = "Bar",
						key = "Bar",
					},
					{
						routeName = "City",
						key = "City",
					},
				},
				index = 3,
			}

			local resultState =
				router.getStateForAction(NavigationActions.navigate({ routeName = "Bar" }), initialState)
			jestExpect(#resultState.routes).toEqual(2)
			jestExpect(resultState.index).toEqual(2)
			jestExpect(resultState.routes[2].routeName).toEqual("Bar")
			jestExpect(resultState.routes[2].params).toEqual(nil)
		end)

		it(
			"should jump to existing entry in stack with existing params if params is not provided, on navigate",
			function()
				local router = StackRouter({
					{ Foo = function() end },
					{ Bar = function() end },
					{ City = function() end },
				})

				local initialState = {
					key = "root",
					routes = {
						{
							routeName = "Foo",
							key = "Foo",
						},
						{
							routeName = "Bar",
							key = "Bar",
							params = { a = 1 },
						},
						{
							routeName = "City",
							key = "City",
						},
					},
					index = 3,
				}

				local resultState =
					router.getStateForAction(NavigationActions.navigate({ routeName = "Bar" }), initialState)
				jestExpect(#resultState.routes).toEqual(2)
				jestExpect(resultState.index).toEqual(2)
				jestExpect(resultState.routes[2].routeName).toEqual("Bar")
				jestExpect(resultState.routes[2].params.a).toEqual(1)
			end
		)

		it("should jump to existing entry in stack with updated params if params is provided, on navigate", function()
			local router = StackRouter({
				{ Foo = function() end },
				{ Bar = function() end },
				{ City = function() end },
			})

			local initialState = {
				key = "root",
				routes = {
					{
						routeName = "Foo",
						key = "Foo",
					},
					{
						routeName = "Bar",
						key = "Bar",
						params = { a = 1 },
					},
					{
						routeName = "City",
						key = "City",
					},
				},
				index = 3,
			}

			local resultState = router.getStateForAction(
				NavigationActions.navigate({
					routeName = "Bar",
					params = { a = 2 },
				}),
				initialState
			)
			jestExpect(#resultState.routes).toEqual(2)
			jestExpect(resultState.index).toEqual(2)
			jestExpect(resultState.routes[2].routeName).toEqual("Bar")
			jestExpect(resultState.routes[2].params.a).toEqual(2)
		end)

		it("should stay at current route in stack if navigate with different params", function()
			local router = StackRouter({
				{ Foo = function() end },
			})

			local initialState = {
				key = "root",
				routes = {
					{
						routeName = "Foo",
						key = "Foo",
					},
				},
				index = 1,
			}

			local resultState = router.getStateForAction(
				NavigationActions.navigate({
					routeName = "Foo",
					params = { a = 1 },
				}),
				initialState
			)
			jestExpect(#resultState.routes).toEqual(1)
			jestExpect(resultState.index).toEqual(1)
			jestExpect(resultState.routes[1].routeName).toEqual("Foo")
			jestExpect(resultState.routes[1].params.a).toEqual(1)
		end)

		it("should stay at current route with existing params if navigate with empty params", function()
			local router = StackRouter({
				{ Foo = function() end },
			})

			local initialState = {
				key = "root",
				routes = {
					{
						routeName = "Foo",
						key = "Foo",
						params = { a = 1 },
					},
				},
				index = 1,
			}

			local resultState = router.getStateForAction(
				NavigationActions.navigate({
					routeName = "Foo",
					params = {},
				}),
				initialState
			)
			jestExpect(#resultState.routes).toEqual(1)
			jestExpect(resultState.index).toEqual(1)
			jestExpect(resultState.routes[1].routeName).toEqual("Foo")
			jestExpect(resultState.routes[1].params.a).toEqual(1)
		end)

		it("should always push new entry on push action even with pre-existing instance of that screen", function()
			local router = StackRouter({
				{ Foo = function() end },
				{ Bar = function() end },
				{ City = function() end },
			})

			local initialState = {
				key = "root",
				routes = {
					{
						routeName = "Foo",
						key = "Foo",
					},
					{
						routeName = "Bar",
						key = "Bar",
					},
					{
						routeName = "City",
						key = "City",
					},
				},
				index = 3,
			}

			local resultState = router.getStateForAction(StackActions.push({ routeName = "Foo" }), initialState)
			jestExpect(#resultState.routes).toEqual(4)
			jestExpect(resultState.index).toEqual(4)
			jestExpect(resultState.routes[4].routeName).toEqual("Foo")
		end)

		it("should navigate to inactive child if route not present elsewhere", function()
			local childRouter = StackRouter({
				{ Bar = { screen = function() end } },
				{ City = { screen = function() end } },
			})

			local router = StackRouter({
				{
					Foo = {
						render = function() end,
						router = childRouter,
					},
				},
				{ Cat = function() end },
			}, {
				initialRouteName = "Cat",
			})

			local initialState = {
				key = "root",
				routes = {
					{
						routeName = "Cat",
						key = "Cat",
					},
				},
				index = 1,
			}

			local resultState =
				router.getStateForAction(NavigationActions.navigate({ routeName = "City" }), initialState)
			jestExpect(#resultState.routes).toEqual(2)
			jestExpect(resultState.index).toEqual(2)
			jestExpect(resultState.routes[2].routeName).toEqual("Foo")

			jestExpect(#resultState.routes[2].routes).toEqual(2)
			jestExpect(resultState.routes[2].index).toEqual(2)
			jestExpect(resultState.routes[2].routes[2].routeName).toEqual("City")
		end)

		it("should set params on route for setParams action", function()
			local router = StackRouter({
				{ Foo = { render = function() end } },
				{ Bar = { render = function() end } },
			}, {
				initialRouteKey = "FooKey",
			})

			local newState = router.getStateForAction(NavigationActions.setParams({
				key = "FooKey",
				params = { a = 1 },
			}))

			jestExpect(newState.routes[newState.index].params.a).toEqual(1)
		end)

		it("should combine params from action and route config", function()
			local router = StackRouter({
				{ Foo = { render = function() end } },
				{
					Bar = {
						screen = function() end,
						params = { a = 1 },
					},
				},
			})

			local state = router.getStateForAction(NavigationActions.init())
			local newState =
				router.getStateForAction(NavigationActions.navigate({ routeName = "Bar", params = { b = 2 } }), state)

			jestExpect(newState.routes[2].params.a).toEqual(1)
			jestExpect(newState.routes[2].params.b).toEqual(2)
		end)

		it("should replace top route if no key is provided", function()
			local router = StackRouter({
				{ Foo = function() end },
				{ Bar = function() end },
			})

			local initialState = {
				key = "root",
				routes = {
					{
						routeName = "Foo",
						key = "Foo",
					},
				},
				index = 1,
			}

			local newState = router.getStateForAction(
				StackActions.replace({
					routeName = "Bar",
				}),
				initialState
			)

			jestExpect(#newState.routes).toEqual(1)
			jestExpect(newState.index).toEqual(1)
			jestExpect(newState.routes[1].routeName).toEqual("Bar")
		end)

		it("should replace keyed route if provided", function()
			local router = StackRouter({
				{ Foo = function() end },
				{ Bar = function() end },
			})

			local initialState = {
				key = "root",
				routes = {
					{
						routeName = "Foo",
						key = "Foo",
					},
					{
						routeName = "Bar",
						key = "Bar",
					},
				},
				index = 2,
			}

			local newState = router.getStateForAction(
				StackActions.replace({
					routeName = "Foo",
					key = "Bar",
					newKey = "NewFoo",
				}),
				initialState
			)

			jestExpect(#newState.routes).toEqual(2)
			jestExpect(newState.index).toEqual(2)
			jestExpect(newState.routes[2].routeName).toEqual("Foo")
			jestExpect(newState.routes[2].key).toEqual("NewFoo")
		end)

		it("should reset top-level routes if not given a key", function()
			local router = StackRouter({
				{ Foo = function() end },
				{ Bar = function() end },
			})

			local initialState = {
				key = "root",
				routes = {
					{ routeName = "Foo", key = "Foo1" },
					{ routeName = "Foo", key = "Foo2" },
				},
				index = 2,
			}

			local resultState = router.getStateForAction(
				StackActions.reset({
					index = 1,
					actions = {
						NavigationActions.navigate({ routeName = "Bar" }),
					},
				}),
				initialState
			)

			-- "actions" array replaces entire state, bypassing initial route config!
			jestExpect(#resultState.routes).toEqual(1)
			jestExpect(resultState.index).toEqual(1)
			jestExpect(resultState.routes[1].routeName).toEqual("Bar")
		end)

		it("should reset keyed route if provided", function()
			local childRouter = StackRouter({
				{ City = function() end },
				{ State = function() end },
			})

			local router = StackRouter({
				{ Foo = function() end },
				{
					Bar = {
						screen = function() end,
						router = childRouter,
					},
				},
			}, {
				initialRouteName = "Bar",
			})

			local initialState = {
				key = "root",
				routes = {
					{
						routeName = "Foo",
						key = "Foo1",
					},
					{
						routeName = "Bar",
						key = "Bar",
						routes = {
							{
								routeName = "City",
								key = "City",
							},
						},
						index = 1,
					},
				},
				index = 2,
			}

			local resultState = router.getStateForAction(
				StackActions.reset({
					actions = {
						NavigationActions.navigate({ routeName = "State" }),
					},
					key = "Bar",
				}),
				initialState
			)

			-- "actions" array replaces entire state, bypassing initial route config!
			jestExpect(#resultState.routes).toEqual(2)
			jestExpect(resultState.index).toEqual(2)
			jestExpect(resultState.routes[2].routeName).toEqual("Bar")
			jestExpect(resultState.routes[2].routes[1].routeName).toEqual("City")
		end)

		it("should mark state as transitioning, then clear it on CompleteTransition action", function()
			local router = StackRouter({
				{ Foo = function() end },
				{ Bar = function() end },
			})

			local initialState = {
				key = "root",
				routes = {
					{
						routeName = "Foo",
						key = "Foo",
					},
				},
				index = 1,
			}

			local transitioningState = router.getStateForAction(StackActions.push({ routeName = "Bar" }), initialState)
			jestExpect(transitioningState.isTransitioning).toEqual(true)

			local completedState = router.getStateForAction(
				StackActions.completeTransition({
					toChildKey = transitioningState.routes[2].key, -- Need actual key to identify target
				}),
				transitioningState
			)

			jestExpect(completedState.isTransitioning).toEqual(false)
		end)

		it(
			"should mark root and child states as transitioning, then separately clear them on CompleteTransition",
			function()
				local childRouter = StackRouter({
					{ BarA = function() end },
					{ BarB = function() end },
				})
				local router = StackRouter({
					{ Foo = function() end },
					{
						Bar = {
							screen = {
								render = function() end,
								router = childRouter,
							},
						},
					},
				})

				local initialState = {
					key = "root",
					routes = {
						{
							routeName = "Foo",
							key = "Foo",
						},
					},
					index = 1,
				}

				local transitioningState =
					router.getStateForAction(NavigationActions.navigate({ routeName = "BarB" }), initialState)
				jestExpect(transitioningState).toBeDefined()
				jestExpect(transitioningState.isTransitioning).toEqual(true)
				jestExpect(transitioningState.routes[2].isTransitioning).toEqual(true)
				jestExpect(transitioningState.routes[2].routes[2].routeName).toEqual("BarB")

				local childOnlyCompletedState = router.getStateForAction(
					StackActions.completeTransition({
						toChildKey = transitioningState.routes[2].routes[2].key,
					}),
					transitioningState
				)
				jestExpect(childOnlyCompletedState.isTransitioning).toEqual(true) -- *** parent needs its own completeTransition call ***
				jestExpect(childOnlyCompletedState.routes[2].isTransitioning).toEqual(false)

				local completedState = router.getStateForAction(
					StackActions.completeTransition({
						toChildKey = transitioningState.routes[2].key,
					}),
					childOnlyCompletedState
				)
				jestExpect(completedState.isTransitioning).toEqual(false)
				jestExpect(completedState.routes[2].isTransitioning).toEqual(false)
			end
		)
	end)
end
