return function()
	local routersModule = script.Parent.Parent
	local RoactNavigationModule = routersModule.Parent
	local RoactNavigation = require(RoactNavigationModule)
	local Packages = RoactNavigationModule.Parent
	local Roact = require(Packages.Roact)
	local jestExpect = require(Packages.Dev.JestRoblox).Globals.expect

	local StackRouter = require(routersModule.StackRouter)
	local TabRouter = require(routersModule.TabRouter)
	local SwitchRouter = require(routersModule.SwitchRouter)
	local NavigationActions = require(RoactNavigationModule.NavigationActions)
	local StackActions = require(routersModule.StackActions)
	local KeyGenerator = require(RoactNavigationModule.utils.KeyGenerator)

	local ROUTERS = {
		TabRouter = TabRouter,
		StackRouter = StackRouter,
		SwitchRouter = SwitchRouter,
	}

	local FooView = Roact.Component:extend("FooView")
	function FooView:render()
		return Roact.createElement("Frame")
	end

	local router, initState, initRoute = nil, nil, nil

	for routerName, Router in pairs(ROUTERS) do
		describe(("Removing params in %s"):format(routerName), function()
			beforeEach(function()
				KeyGenerator._TESTING_ONLY_normalize_keys()

				router = Router({
					{ Foo = { screen = FooView } },
					{ Bar = { screen = FooView } },
				})
				initState = router.getStateForAction(NavigationActions.init())
				initRoute = initState.routes[initState.index]
			end)

			it("setParams clears individual params using RoactNavigation.None", function()
				local state0 = router.getStateForAction(
					NavigationActions.setParams({ params = {foo = 42}, key = initRoute.key }),
					initState
				)

				jestExpect(state0.routes[state0.index]).toEqual(
					jestExpect.objectContaining({ params = { foo = 42 } })
				)

				local state1 = router.getStateForAction(
					NavigationActions.setParams({ params = {foo = RoactNavigation.None}, key = initRoute.key }),
					state0
				)

				jestExpect(state1.routes[state1.index].params.foo).toBeNil()
			end)

			it("navigate clears individual params using RoactNavigation.None", function()	
				local state0 = router.getStateForAction(
					NavigationActions.setParams({ params = {foo = 10, bar = 20}, key = initRoute.key }),
					initState
				)

				jestExpect(state0.routes[state0.index]).toEqual(
					jestExpect.objectContaining({ params = { foo = 10, bar = 20 } })
				)

				local state1 = router.getStateForAction(
					NavigationActions.navigate({ params = {bar = RoactNavigation.None}, routeName = "Foo" }),
					state0
				)

				jestExpect(state1.routes[state1.index]).toEqual(
					jestExpect.objectContaining({ params = { foo = 10 } })
				)
			end)

			it("setParams removes entire params with RoactNavigation.None", function()
				local state0 = router.getStateForAction(
					NavigationActions.setParams({ params = {foo = 42}, key = initRoute.key }),
					initState
				)

				jestExpect(state0.routes[state0.index]).toEqual(
					jestExpect.objectContaining({ params = { foo = 42 } })
				)

				local state1 = router.getStateForAction(
					NavigationActions.setParams({ params = RoactNavigation.None, key = initRoute.key }),
					initState
				)

				jestExpect(state1.routes[state1.index].params).toBeNil()
			end)

			it("navigate removes entire params with RoactNavigation.None", function()
				local state0 = router.getStateForAction(
					NavigationActions.setParams({ params = {foo = 10, bar = 20}, key = initRoute.key }),
					initState
				)

				jestExpect(state0.routes[state0.index]).toEqual(
					jestExpect.objectContaining({ params = { foo = 10, bar = 20 } })
				)

				local state1 = router.getStateForAction(
					NavigationActions.navigate({ params = RoactNavigation.None, routeName = "Bar" }),
					state0
				)

				jestExpect(state1.routes[state1.index].params).toBeNil()
			end)

		end)
	end

	describe("Removing params with StackActions.push", function()
		beforeEach(function()
			KeyGenerator._TESTING_ONLY_normalize_keys()

			router = StackRouter({
				{ Foo = { screen = FooView } },
				{ Bar = { screen = FooView } },
			})
			initState = router.getStateForAction(NavigationActions.init())
			initRoute = initState.routes[initState.index]
		end)

		it("StackActions.push clears individual params with RoactNavigation.None", function()
			local state0 = router.getStateForAction(
				StackActions.push({
					routeName = "Bar",
					params = { foo = 42 },
				}),
				initState
			)
	
			jestExpect(state0.routes[state0.index]).toEqual(
				jestExpect.objectContaining({ params = { foo = 42 } })
			)
	
			local state1 = router.getStateForAction(
				StackActions.push({
					routeName = "Bar",
					params = { foo = RoactNavigation.None },
				}),
				initState
			)
	
			jestExpect(state1.routes[state1.index].params.foo).toBeNil()
	
		end)
	
		it("StackActions.push clears entire params with RoactNavigation.None", function()
			local state0 = router.getStateForAction(
				StackActions.push({
					routeName = "Bar",
					params = { foo = 42 },
				}),
				initState
			)
	
			jestExpect(state0.routes[state0.index]).toEqual(
				jestExpect.objectContaining({ params = { foo = 42 } })
			)
	
			local state1 = router.getStateForAction(
				StackActions.push({
					routeName = "Bar",
					params = RoactNavigation.None,
				}),
				state0
			)
	
			jestExpect(state1.routes[state1.index].params).toBeNil()
		end)
	end)

end
