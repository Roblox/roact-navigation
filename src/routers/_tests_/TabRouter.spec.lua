-- upstream https://github.com/react-navigation/react-navigation/blob/72e8160537954af40f1b070aa91ef45fc02bba69/packages/core/src/routers/__tests__/TabRouter.test.js

return function()
	local routersModule = script.Parent.Parent
	local RoactNavigationModule = routersModule.Parent
	local Packages = RoactNavigationModule.Parent
	local Roact = require(Packages.Roact)
	local jestExpect = require(Packages.Dev.JestRoblox).Globals.expect

	local BackBehavior = require(RoactNavigationModule.BackBehavior)
	local NavigationActions = require(RoactNavigationModule.NavigationActions)
	local TabRouter = require(routersModule.TabRouter)

	local BareLeafRouteConfig = {
		screen = function()
			return Roact.createElement("Frame")
		end,
	}

	local INIT_ACTION = { type = NavigationActions.Init }

	describe("TabRouter", function()
		it("Handles basic tab logic", function()
			local function ScreenA()
				return Roact.createElement("Frame")
			end
			local function ScreenB()
				return Roact.createElement("Frame")
			end
			local router = TabRouter({
				{ Foo = { screen = ScreenA } },
				{ Bar = { screen = ScreenB } },
			})
			local state = router.getStateForAction({
				type = NavigationActions.Init,
			})
			local expectedState = {
				index = 1,
				routes = {
					{ key = "Foo", routeName = "Foo" },
					{ key = "Bar", routeName = "Bar" },
				},
			}

			jestExpect(state).toEqual(expectedState)

			local state2 = router.getStateForAction({
				type = NavigationActions.Navigate,
				routeName = "Bar",
			}, state)
			local expectedState2 = {
				index = 2,
				routes = {
					{ key = "Foo", routeName = "Foo" },
					{ key = "Bar", routeName = "Bar" },
				},
			}

			jestExpect(state2).toEqual(expectedState2)
			jestExpect(router.getComponentForState(expectedState)).toBe(ScreenA)
			jestExpect(router.getComponentForState(expectedState2)).toBe(ScreenB)

			local state3 = router.getStateForAction({
				type = NavigationActions.Navigate,
				routeName = "Bar",
			}, state2)

			jestExpect(state3).toEqual(nil)
		end)

		it("Handles getScreen", function()
			local function ScreenA()
				return Roact.createElement("Frame")
			end
			local function ScreenB()
				return Roact.createElement("Frame")
			end
			local router = TabRouter({
				{ Foo = { getScreen = function() return ScreenA end } },
				{ Bar = { getScreen = function() return ScreenB end } },
			})
			local state = router.getStateForAction({
				type = NavigationActions.Init,
			})
			local expectedState = {
				index = 1,
				routes = {
					{ key = "Foo", routeName = "Foo" },
					{ key = "Bar", routeName = "Bar" },
				},
			}

			jestExpect(state).toEqual(expectedState)

			local state2 = router.getStateForAction({
				type = NavigationActions.Navigate,
				routeName = "Bar",
			}, state)
			local expectedState2 = {
				index = 2,
				routes = {
					{ key = "Foo", routeName = "Foo" },
					{ key = "Bar", routeName = "Bar" },
				},
			}

			jestExpect(state2).toEqual(expectedState2)
			jestExpect(router.getComponentForState(expectedState)).toBe(ScreenA)
			jestExpect(router.getComponentForState(expectedState2)).toBe(ScreenB)

			local state3 = router.getStateForAction({
				type = NavigationActions.Navigate,
				routeName = "Bar",
			}, state2)

			jestExpect(state3).toEqual(nil)
		end)

		it("Can set the initial tab", function()
			local router = TabRouter({
				{ Foo = BareLeafRouteConfig },
				{ Bar = BareLeafRouteConfig },
			}, {
				initialRouteName = "Bar",
			})
			local state = router.getStateForAction({ type = NavigationActions.Init })

			jestExpect(state).toEqual({
				index = 2,
				routes = {
					{ key = "Foo", routeName = "Foo" },
					{ key = "Bar", routeName = "Bar" },
				},
			})
		end)

		it("Can set the initial params", function()
			local router = TabRouter({
				{ Foo = BareLeafRouteConfig },
				{ Bar = BareLeafRouteConfig },
			}, {
				initialRouteName = "Bar",
				initialRouteParams = { name = "Qux" },
			})
			local state = router.getStateForAction({ type = NavigationActions.Init })

			jestExpect(state).toEqual({
				index = 2,
				routes = {
					{ key = "Foo", routeName = "Foo" },
					{ key = "Bar", routeName = "Bar", params = { name = "Qux" } },
				},
			})
		end)

		it("Handles the SetParams action", function()
			local router = TabRouter({
				{
					Foo = {
						screen = function() return Roact.createElement("Frame") end,
					},
				},
				{
					Bar = {
						screen = function() return Roact.createElement("Frame") end,
					},
				},
			})
			local state2 = router.getStateForAction({
				type = NavigationActions.SetParams,
				params = { name = "Qux" },
				key = "Foo",
			})

			jestExpect(state2 and state2.routes[1].params).toEqual({
				name = "Qux",
			})
		end)

		it("Handles the SetParams action for inactive routes", function()
			local router = TabRouter({
				{
					Foo = {
						screen = function() return Roact.createElement("Frame") end,
					},
				},
				{
					Bar = {
						screen = function() return Roact.createElement("Frame") end,
					},
				},
			}, {
				initialRouteName = "Bar",
			})
			local initialState = {
				index = 2,
				routes = {
					{
						key = "RouteA",
						routeName = "Foo",
						params = { name = "InitialParam", other = "Unchanged" },
					},
					{ key = "RouteB", routeName = "Bar", params = {} },
				},
			}
			local state = router.getStateForAction({
				type = NavigationActions.SetParams,
				params = { name = "NewParam" },
				key = "RouteA",
			}, initialState)

			jestExpect(state.index).toEqual(2)
			jestExpect(state.routes[1].params).toEqual({
				name = "NewParam",
				other = "Unchanged",
			})
		end)

		it("getStateForAction returns null when navigating to same tab", function()
			local router = TabRouter({
				{ Foo = BareLeafRouteConfig },
				{ Bar = BareLeafRouteConfig },
			}, {
				initialRouteName = "Bar",
			})
			local state = router.getStateForAction({
				type = NavigationActions.Init,
			})
			local state2 = router.getStateForAction({
				type = NavigationActions.Navigate,
				routeName = "Bar",
			}, state)

			jestExpect(state2).toEqual(nil)
		end)

		it("getStateForAction returns initial navigate", function()
			local router = TabRouter({
				{ Foo = BareLeafRouteConfig },
				{ Bar = BareLeafRouteConfig },
			})
			local state = router.getStateForAction({
				type = NavigationActions.Navigate,
				routeName = "Foo",
			})

			jestExpect(state and state.index).toEqual(1)
		end)

		it("Handles nested tabs and nested actions", function()
			local ChildTabNavigator = Roact.Component:extend("ChildTabNavigator")

			function ChildTabNavigator:render()
				return Roact.createElement("Frame")
			end

			ChildTabNavigator.router = TabRouter({
				{ Foo = BareLeafRouteConfig },
				{ Bar = BareLeafRouteConfig },
			})

			local router = TabRouter({
				{ Foo = BareLeafRouteConfig },
				{ Baz = { screen = ChildTabNavigator } },
				{ Boo = BareLeafRouteConfig },
			})
			local action = router.getActionForPathAndParams("Baz/Bar", { foo = "42" })
			local navAction = {
				type = NavigationActions.Navigate,
				routeName = "Baz",
				params = { foo = "42" },
				action = {
					type = NavigationActions.Navigate,
					routeName = "Bar",
					params = { foo = "42" },
				},
			}

			jestExpect(action).toEqual(navAction)

			local state = router.getStateForAction(navAction)

			jestExpect(state).toEqual({
				index = 2,
				routes = {
					{ key = "Foo", routeName = "Foo" },
					{
						index = 2,
						key = "Baz",
						routeName = "Baz",
						params = { foo = "42" },
						routes = {
							{ key = "Foo", routeName = "Foo" },
							{
								key = "Bar",
								routeName = "Bar",
								params = { foo = "42" },
							},
						},
					},
					{ key = "Boo", routeName = "Boo" },
				},
			})
		end)

		it("Handles passing params to nested tabs", function()
			local ChildTabNavigator = Roact.Component:extend("ChildTabNavigator")

			function ChildTabNavigator:render()
				return Roact.createElement("Frame")
			end

			ChildTabNavigator.router = TabRouter({
				{ Boo = BareLeafRouteConfig },
				{ Bar = BareLeafRouteConfig },
			})

			local router = TabRouter({
				{ Foo = BareLeafRouteConfig },
				{ Baz = { screen = ChildTabNavigator } },
			})
			local navAction = {
				type = NavigationActions.Navigate,
				routeName = "Baz",
			}
			local state = router.getStateForAction(navAction)

			jestExpect(state).toEqual({
				index = 2,
				routes = {
					{ key = "Foo", routeName = "Foo" },
					{
						index = 1,
						key = "Baz",
						routeName = "Baz",
						routes = {
							{ key = "Boo", routeName = "Boo" },
							{ key = "Bar", routeName = "Bar" },
						},
					},
				},
			})

			-- Ensure that navigating back and forth doesn't overwrite
			state = router.getStateForAction(
				{ type = NavigationActions.Navigate, routeName = "Bar" },
				state
			)
			state = router.getStateForAction(
				{ type = NavigationActions.Navigate, routeName = "Boo" },
				state
			)

			jestExpect(state and state.routes[2]).toEqual({
				index = 1,
				key = "Baz",
				routeName = "Baz",
				routes = {
					{ key = "Boo", routeName = "Boo" },
					{ key = "Bar", routeName = "Bar" },
				},
			})
		end)

		it("Handles initial deep linking into nested tabs", function()
			local ChildTabNavigator = Roact.Component:extend("ChildTabNavigator")

			function ChildTabNavigator:render()
				return Roact.createElement("Frame")
			end

			ChildTabNavigator.router = TabRouter({
				{ Foo = BareLeafRouteConfig },
				{ Bar = BareLeafRouteConfig },
			})

			local router = TabRouter({
				{ Foo = BareLeafRouteConfig },
				{ Baz = { screen = ChildTabNavigator } },
				{ Boo = BareLeafRouteConfig },
			})
			local state = router.getStateForAction({
				type = NavigationActions.Navigate,
				routeName = "Bar",
			})

			jestExpect(state).toEqual({
				index = 2,
				routes = {
					{ key = "Foo", routeName = "Foo" },
					{
						index = 2,
						key = "Baz",
						routeName = "Baz",
						routes = {
							{ key = "Foo", routeName = "Foo" },
							{ key = "Bar", routeName = "Bar" },
						},
					},
					{ key = "Boo", routeName = "Boo" },
				},
			})

			local state2 = router.getStateForAction(
				{ type = NavigationActions.Navigate, routeName = "Foo" },
				state
			)
			jestExpect(state2).toEqual({
				index = 2,
				routes = {
					{ key = "Foo", routeName = "Foo" },
					{
						index = 1,
						key = "Baz",
						routeName = "Baz",
						routes = {
							{ key = "Foo", routeName = "Foo" },
							{ key = "Bar", routeName = "Bar" },
						},
					},
					{ key = "Boo", routeName = "Boo" },
				},
			})

			local state3 = router.getStateForAction(
				{ type = NavigationActions.Navigate, routeName = "Foo" },
				state2
			)
			jestExpect(state3).toEqual(nil)
		end)

		it("Handles linking across of deeply nested tabs", function()
			local ChildNavigator0 = Roact.Component:extend("ChildNavigator0")
			function ChildNavigator0:render()
				return Roact.createElement("Frame")
			end

			ChildNavigator0.router = TabRouter({
				{ Boo = BareLeafRouteConfig },
				{ Baz = BareLeafRouteConfig },
			})

			local ChildNavigator1 = Roact.Component:extend("ChildNavigator1")
			function ChildNavigator1:render()
				return Roact.createElement("Frame")
			end

			ChildNavigator1.router = TabRouter({
				{ Zoo = BareLeafRouteConfig },
				{ Zap = BareLeafRouteConfig },
			})

			local MidNavigator = Roact.Component:extend("MidNavigator")
			function MidNavigator:render()
				return Roact.createElement("Frame")
			end

			MidNavigator.router = TabRouter({
				{ Fee = { screen = ChildNavigator0 } },
				{ Bar = { screen = ChildNavigator1 } },
			})

			local router = TabRouter({
				{ Foo = { screen = MidNavigator } },
				{ Gah = BareLeafRouteConfig },
			})
			local state = router.getStateForAction(INIT_ACTION)

			jestExpect(state).toEqual({
				index = 1,
				routes = {
					{
						index = 1,
						key = "Foo",
						routeName = "Foo",
						routes = {
							{
								index = 1,
								key = "Fee",
								routeName = "Fee",
								routes = {
									{ key = "Boo", routeName = "Boo" },
									{ key = "Baz", routeName = "Baz" },
								},
							},
							{
								index = 1,
								key = "Bar",
								routeName = "Bar",
								routes = {
									{ key = "Zoo", routeName = "Zoo" },
									{ key = "Zap", routeName = "Zap" },
								},
							},
						},
					},
					{ key = "Gah", routeName = "Gah" },
				},
			})

			local state2 = router.getStateForAction(
				{ type = NavigationActions.Navigate, routeName = "Zap" },
				state
			)

			jestExpect(state2).toEqual({
				index = 1,
				routes = {
					{
						index = 2,
						key = "Foo",
						routeName = "Foo",
						routes = {
							{
								index = 1,
								key = "Fee",
								routeName = "Fee",
								routes = {
									{ key = "Boo", routeName = "Boo" },
									{ key = "Baz", routeName = "Baz" },
								},
							},
							{
								index = 2,
								key = "Bar",
								routeName = "Bar",
								routes = {
									{ key = "Zoo", routeName = "Zoo" },
									{ key = "Zap", routeName = "Zap" },
								},
							},
						},
					},
					{ key = "Gah", routeName = "Gah" },
				},
			})

			local state3 = router.getStateForAction(
				{ type = NavigationActions.Navigate, routeName = "Zap" },
				state2
			)

			jestExpect(state3).toEqual(nil)

			local state4 = router.getStateForAction({
				type = NavigationActions.Navigate,
				routeName = "Foo",
				action = {
					type = NavigationActions.Navigate,
					routeName = "Bar",
					action = { type = NavigationActions.Navigate, routeName = "Zap" },
				},
			})

			jestExpect(state4).toEqual({
				index = 1,
				routes = {
					{
						index = 2,
						key = "Foo",
						routeName = "Foo",
						routes = {
							{
								index = 1,
								key = "Fee",
								routeName = "Fee",
								routes = {
									{ key = "Boo", routeName = "Boo" },
									{ key = "Baz", routeName = "Baz" },
								},
							},
							{
								index = 2,
								key = "Bar",
								routeName = "Bar",
								routes = {
									{ key = "Zoo", routeName = "Zoo" },
									{ key = "Zap", routeName = "Zap" },
								},
							},
						},
					},
					{ key = "Gah", routeName = "Gah" },
				},
			})
		end)

		it("Handles path configuration", function()
			local function ScreenA()
				return Roact.createElement("Frame")
			end
			local function ScreenB()
				return Roact.createElement("Frame")
			end
			local router = TabRouter({
				{ Foo = { path = "f", screen = ScreenA } },
				{ Bar = { path = "b/:great", screen = ScreenB } },
			})
			local params = { foo = "42" }
			local action = router.getActionForPathAndParams("b/anything", params)
			local expectedAction = {
				params = {
					foo = "42",
					great = "anything",
				},
				routeName = "Bar",
				type = NavigationActions.Navigate,
			}

			jestExpect(action).toEqual(expectedAction)

			local state = router.getStateForAction({ type = NavigationActions.Init })
			local expectedState = {
				index = 1,
				routes = {
					{ key = "Foo", routeName = "Foo" },
					{ key = "Bar", routeName = "Bar" },
				},
			}

			jestExpect(state).toEqual(expectedState)

			local state2 = router.getStateForAction(expectedAction, state)
			local expectedState2 = {
				index = 2,
				routes = {
					{ key = "Foo", routeName = "Foo", params = nil },
					{
						key = "Bar",
						routeName = "Bar",
						params = { foo = "42", great = "anything" },
					},
				},
			}

			jestExpect(state2).toEqual(expectedState2)
			jestExpect(router.getComponentForState(expectedState)).toBe(ScreenA)
			jestExpect(router.getComponentForState(expectedState2)).toBe(ScreenB)
			jestExpect(router.getPathAndParamsForState(expectedState).path).toEqual("f")
			jestExpect(router.getPathAndParamsForState(expectedState2).path).toEqual("b/anything")
		end)

		it("Handles default configuration", function()
			local function ScreenA()
				return Roact.createElement("Frame")
			end
			local function ScreenB()
				return Roact.createElement("Frame")
			end
			local router = TabRouter({
				{ Foo = { path = "", screen = ScreenA } },
				{ Bar = { path = "b", screen = ScreenB } },
			})
			local action = router.getActionForPathAndParams("", { foo = "42" })

			jestExpect(action).toEqual({
				params = { foo = "42" },
				routeName = "Foo",
				type = NavigationActions.Navigate,
			})
		end)

		it("Gets deep path", function()
			local ScreenA = Roact.Component:extend("ScreenA")
			function ScreenA:render()
				return Roact.createElement("Frame")
			end
			local function ScreenB()
				return Roact.createElement("Frame")
			end

			ScreenA.router = TabRouter({
				{ Baz = { screen = ScreenB } },
				{ Boo = { screen = ScreenB } },
			})

			local router = TabRouter({
				{ Foo = { path = "f", screen = ScreenA } },
				{ Bar = { screen = ScreenB } },
			})
			local state = {
				index = 1,
				routes = {
					{
						index = 2,
						key = "Foo",
						routeName = "Foo",
						routes = {
							{ key = "Boo", routeName = "Boo" },
							{ key = "Baz", routeName = "Baz" },
						},
					},
					{ key = "Bar", routeName = "Bar" },
				},
			}
			local path = router.getPathAndParamsForState(state).path

			jestExpect(path).toEqual("f/Baz")
		end)

		it("Can navigate to other tab (no router) with params", function()
			local function ScreenA()
				return Roact.createElement("Frame")
			end
			local function ScreenB()
				return Roact.createElement("Frame")
			end
			local router = TabRouter({
				{ a = { screen = ScreenA } },
				{ b = { screen = ScreenB } },
			})
			local state0 = router.getStateForAction(INIT_ACTION)

			jestExpect(state0).toEqual({
				index = 1,
				routes = {
					{ key = "a", routeName = "a" },
					{ key = "b", routeName = "b" },
				},
			})

			local params = { key = "value" }
			local state1 = router.getStateForAction({
				type = NavigationActions.Navigate,
				routeName = "b",
				params = params,
			}, state0)

			jestExpect(state1).toEqual({
				index = 2,
				routes = {
					{ key = "a", routeName = "a" },
					{ key = "b", routeName = "b", params = params },
				},
			})
		end)

		it("Back actions are not propagated to inactive children", function()
			local function ScreenA()
				return Roact.createElement("Frame")
			end
			local function ScreenB()
				return Roact.createElement("Frame")
			end
			local function ScreenC()
				return Roact.createElement("Frame")
			end
			local InnerNavigator = Roact.Component:extend("InnerNavigator")
			function InnerNavigator:render()
				return Roact.createElement("Frame")
			end

			InnerNavigator.router = TabRouter({
				{ a = { screen = ScreenA } },
				{ b = { screen = ScreenB } },
			})

			local router = TabRouter({
				{ inner = { screen = InnerNavigator } },
				{ c = { screen = ScreenC } },
			}, {
				backBehavior = BackBehavior.None,
			})
			local state0 = router.getStateForAction(INIT_ACTION)
			local state1 = router.getStateForAction(
				{ type = NavigationActions.Navigate, routeName = "b" },
				state0
			)
			local state2 = router.getStateForAction(
				{ type = NavigationActions.Navigate, routeName = "c" },
				state1
			)
			local state3 = router.getStateForAction(
				{ type = NavigationActions.Back },
				state2
			)

			jestExpect(state3).toEqual(state2)
		end)

		it("Back behavior initialRoute works", function()
			local function ScreenA()
				return Roact.createElement("Frame")
			end
			local function ScreenB()
				return Roact.createElement("Frame")
			end
			local router = TabRouter({
				{ a = { screen = ScreenA } },
				{ b = { screen = ScreenB } },
			})
			local state0 = router.getStateForAction(INIT_ACTION)
			local state1 = router.getStateForAction(
				{ type = NavigationActions.Navigate, routeName = "b" },
				state0
			)
			local state2 = router.getStateForAction(
				{ type = NavigationActions.Back },
				state1
			)

			jestExpect(state2).toEqual(state0)
		end)

		it("Inner actions are only unpacked if the current tab matches", function()
			local PlainScreen = function()
				return Roact.createElement("Frame")
			end
			local ScreenA = Roact.Component:extend("ScreenA")
			function ScreenA:render()
				return Roact.createElement("Frame")
			end
			local ScreenB = Roact.Component:extend("ScreenB")
			function ScreenB:render()
				return Roact.createElement("Frame")
			end

			ScreenB.router = TabRouter({
				{ Baz = { screen = PlainScreen } },
				{ Zoo = { screen = PlainScreen } },
			})
			ScreenA.router = TabRouter({
				{ Bar = { screen = PlainScreen } },
				{ Boo = { screen = ScreenB } },
			})
			local router = TabRouter({
				{ Foo = { screen = ScreenA } },
			})

			local screenApreState = {
				index = 1,
				key = "Foo",
				routeName = "Foo",
				routes = {
					{ key = "Bar", routeName = "Bar" },
				},
			}
			local preState = {
				index = 1,
				routes = { screenApreState },
			}

			local function comparable(state)
				local result = {}

				if typeof(state.routeName) == "string" then
					result.routeName = state.routeName
				end
				if typeof(state.routes) == 'table' then
					result.routes = {}
					for i=1, #state.routes do
						result.routes[i] = comparable(state.routes[i])
					end
				end

				return result
			end

			local action = NavigationActions.navigate({
				routeName = "Boo",
				action = NavigationActions.navigate({ routeName = "Zoo" }),
			})
			local expectedState = ScreenA.router.getStateForAction(action, screenApreState)
			local state = router.getStateForAction(action, preState)
			local innerState = state and state.routes[1] or state

			jestExpect(innerState.routes[2].index).toEqual(2)
			jestExpect(expectedState and comparable(expectedState)).toEqual(
				innerState and comparable(innerState)
			)

			local noMatchAction = NavigationActions.navigate({
				routeName = "Qux",
				action = NavigationActions.navigate({ routeName = "Zoo" }),
			})
			local expectedState2 = ScreenA.router.getStateForAction(noMatchAction, screenApreState)
			local state2 = router.getStateForAction(noMatchAction, preState)
			local innerState2 = state2 and state2.routes[1] or state2

			jestExpect(innerState2.routes[2].index).toEqual(1)
			jestExpect(expectedState2 and comparable(expectedState2)).toEqual(
				innerState2 and comparable(innerState2)
			)
		end)
	end)
end
