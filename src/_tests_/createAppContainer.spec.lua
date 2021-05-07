local LogService = game:GetService("LogService")

return function()
	local RoactNavigationModule = script.Parent.Parent
	local Packages = RoactNavigationModule.Parent
	local Roact = require(Packages.Roact)
	local jestExpect = require(Packages.Dev.JestRoblox).Globals.expect
	local NavigationActions = require(RoactNavigationModule.NavigationActions)
	local createNavigator = require(RoactNavigationModule.navigators.createNavigator)
	local createAppContainerExports = require(RoactNavigationModule.createAppContainer)
	local createAppContainer = createAppContainerExports.createAppContainer
	local _TESTING_ONLY_reset_container_count = createAppContainerExports._TESTING_ONLY_reset_container_count

	local StackRouter = require(RoactNavigationModule.routers.StackRouter)
	local SwitchView = require(RoactNavigationModule.views.SwitchView.SwitchView)
	local createSpy = require(RoactNavigationModule.utils.createSpy)
	local waitUntil = require(RoactNavigationModule.utils.waitUntil)

	local function createStackNavigator(routeConfigMap, stackConfig)
		local router = StackRouter(routeConfigMap, stackConfig)
		return createAppContainer(createNavigator(SwitchView, router, stackConfig))
	end

	describe("NavigationContainer", function()
		beforeEach(function()
			_TESTING_ONLY_reset_container_count()
		end)

		local function FooScreen()
			return Roact.createElement("Frame")
		end
		local function BarScreen()
			return Roact.createElement("Frame")
		end
		local function BazScreen()
			return Roact.createElement("Frame")
		end
		local function CarScreen()
			return Roact.createElement("Frame")
		end
		local function DogScreen()
			return Roact.createElement("Frame")
		end
		local function ElkScreen()
			return Roact.createElement("Frame")
		end
		local Stack = createStackNavigator({
			{ foo = { screen = FooScreen } },
			{ bar = { screen = BarScreen } },
			{ baz = { screen = BazScreen } },
			{ car = { screen = CarScreen } },
			{ dog = { screen = DogScreen } },
			{ elk = { screen = ElkScreen } },
		}, {
			initialRouteName = "foo",
		})

		-- deviation: utility function to capture the component state. This
		-- is necessary because Roact cannot provide the mounted component
		-- like React.
		-- The function takes a callback as an argument that will give the
		-- value of the component instance.
		local function createTestableNavigationContainer(setValue)
			local wrapNavigationContainer = createAppContainer(Stack)

			local originalInit = wrapNavigationContainer.init
			wrapNavigationContainer.init = function(self)
				setValue(self)
				originalInit(self)
			end

			return wrapNavigationContainer
		end

		describe("state.nav", function()
			it("should be preloaded with the router's initial state", function()
				local navigationContainer = nil
				local NavigationContainer = createTestableNavigationContainer(function(self)
					navigationContainer = self
				end)

				Roact.mount(Roact.createElement(NavigationContainer))

				jestExpect(navigationContainer.state.nav).toMatchObject({ index = 1 })
				jestExpect(navigationContainer.state.nav.routes).toEqual(jestExpect.any("table"))
				jestExpect(#navigationContainer.state.nav.routes).toBe(1)
				jestExpect(navigationContainer.state.nav.routes[1]).toMatchObject({
					routeName = "foo",
				})
			end)
		end)

		describe("dispatch", function()
			it("returns true when given a valid action", function()
				local navigationContainer = nil
				local NavigationContainer = createTestableNavigationContainer(function(value)
					navigationContainer = value
				end)

				Roact.mount(Roact.createElement(NavigationContainer))

				-- jest.runOnlyPendingTimers()

				jestExpect(
					navigationContainer:dispatch(
						NavigationActions.navigate({ routeName = "bar" })
					)
				).toEqual(true)
			end)

			it("returns false when given an invalid action", function()
				local navigationContainer = nil
				local NavigationContainer = createTestableNavigationContainer(function(value)
					navigationContainer = value
				end)

				Roact.mount(Roact.createElement(NavigationContainer))

				-- jest.runOnlyPendingTimers()
				jestExpect(navigationContainer:dispatch(NavigationActions.back())).toEqual(false)
			end)

			it("updates state.nav with an action by the next tick", function()
				local navigationContainer = nil
				local NavigationContainer = createTestableNavigationContainer(function(value)
					navigationContainer = value
				end)

				Roact.mount(Roact.createElement(NavigationContainer))

				jestExpect(
					navigationContainer:dispatch(
						NavigationActions.navigate({ routeName = "bar" })
					)
				).toEqual(true)

				-- Fake the passing of a tick
				-- jest.runOnlyPendingTimers()

				jestExpect(navigationContainer.state.nav).toMatchObject({
					index = 2,
					routes = {{ routeName = "foo" }, { routeName = "bar" }},
				})
			end)

			it("does not discard actions when called twice in one tick", function()
				local navigationContainer = nil
				local NavigationContainer = createTestableNavigationContainer(function(value)
					navigationContainer = value
				end)
				Roact.mount(Roact.createElement(NavigationContainer))

				-- First dispatch
				jestExpect(
					navigationContainer:dispatch(
						NavigationActions.navigate({ routeName = "bar" })
					)
				).toEqual(true)

				-- Make sure that the test runner has NOT synchronously applied setState before the tick
				-- jestExpect(navigationContainer.state.nav).toMatchObject(initialState)

				-- Second dispatch
				jestExpect(
					navigationContainer:dispatch(
						NavigationActions.navigate({ routeName = "baz" })
					)
				).toEqual(true)

				-- Fake the passing of a tick
				-- jest.runOnlyPendingTimers()

				jestExpect(navigationContainer.state.nav).toMatchObject({
					index = 3,
					routes = {
						{ routeName = "foo" },
						{ routeName = "bar" },
						{ routeName = "baz" },
					},
				})
			end)

			it("does not discard actions when called more than 2 times in one tick", function()
				local navigationContainer = nil
				local NavigationContainer = createTestableNavigationContainer(function(value)
					navigationContainer = value
				end)
				Roact.mount(Roact.createElement(NavigationContainer))

				-- First dispatch
				jestExpect(
					navigationContainer:dispatch(
						NavigationActions.navigate({ routeName = "bar" })
					)
				).toEqual(true)

				-- Make sure that the test runner has NOT synchronously applied setState before the tick
				-- jestExpect(navigationContainer.state.nav).toMatchObject(initialState);

				-- Second dispatch
				jestExpect(
					navigationContainer:dispatch(
						NavigationActions.navigate({ routeName = "baz" })
					)
				).toEqual(true)

				-- Third dispatch
				jestExpect(
					navigationContainer:dispatch(
						NavigationActions.navigate({ routeName = "car" })
					)
				).toEqual(true)

				-- Fourth dispatch
				jestExpect(
					navigationContainer:dispatch(
						NavigationActions.navigate({ routeName = "dog" })
					)
				).toEqual(true)

				-- Fifth dispatch
				jestExpect(
					navigationContainer:dispatch(
						NavigationActions.navigate({ routeName = "elk" })
					)
				).toEqual(true)

				-- Fake the passing of a tick
				-- jest.runOnlyPendingTimers()

				jestExpect(navigationContainer.state.nav).toMatchObject({
					index = 6,
					routes = {
						{ routeName = "foo" },
						{ routeName = "bar" },
						{ routeName = "baz" },
						{ routeName = "car" },
						{ routeName = "dog" },
						{ routeName = "elk" },
					},
				})
			end)
		end)

		describe("warnings", function()
			describe("detached navigators", function()
				-- deviation: this is not required with our current implementation
				-- and probably should not be. Until lua-apps adopts it for the whole
				-- app, Roact Navigation will probably need to support multiple
				-- containers in the app.
				itSKIP("warns when you render more than one container explicitly")
			end)
		end)

		-- deviation: no need for flushPromises since we don't have promise/async callbacks

		describe("state persistence", function()
			local function createPersistenceEnabledContainer(loadNavigationState, persistNavigationState)
				if persistNavigationState == nil then
					persistNavigationState = createSpy()
				end
				local navContainer = nil
				local NavigationContainer = createTestableNavigationContainer(function(value)
					navContainer = value
				end)

				-- deviation: we simulate flushPromise by wrapping loadNavigationState
				local loadNavigationDone = false

				Roact.mount(Roact.createElement(NavigationContainer, {
					persistNavigationState = persistNavigationState.value,
					loadNavigationState = function(...)
						local success, resultOrError = pcall(loadNavigationState.value, ...)
						loadNavigationDone = true
						if not success then
							error(resultOrError)
						end
						return resultOrError
					end,
				}))

				-- wait for loadNavigationState() to resolve
				-- deviation: we wait until loadNavigationState is done
				waitUntil(function()
					return loadNavigationDone
				end)

				return navContainer
			end

			it("loadNavigationState is called upon mount and persistNavigationState is called on a nav state change", function()
				local persistNavigationState = createSpy()
				local loadNavigationState = createSpy(function()
					return {
						index = 2,
						routes = {
							{ routeName = "foo", key = "foo" },
							{ routeName = "bar", key = "bar" },
						},
					}
				end)
				local navigationContainer = createPersistenceEnabledContainer(loadNavigationState, persistNavigationState)

				jestExpect(loadNavigationState.callCount).never.toEqual(0)
				-- jest.runOnlyPendingTimers()
				navigationContainer:dispatch(
					NavigationActions.navigate({ routeName = "foo" })
				)

				-- jest.runOnlyPendingTimers()
				wait()

				persistNavigationState:assertCalledWithDeepEqual({
					index = 1,
					isTransitioning = true,
					routes = {
						{ routeName = "foo", key = "foo" },
					},
				})
			end)

			it("when persistNavigationState rejects, a console warning is shown", function()
				-- deviation: instead of spying on warn, we simply connect to MessageOut event
				local expectedWarning = "Uncaught error while calling persistNavigationState()!"
				local warningFound = false
				local connection = LogService.MessageOut:Connect(function(message, messageType)
					if messageType == Enum.MessageType.MessageWarning then
						if not warningFound and message:find(expectedWarning, 1, true) ~= nil then
							warningFound = true
						end
					end
				end)

				local persistNavigationState = createSpy(function()
					error('persistNavigationState failed')
				end)
				local loadNavigationState = createSpy(function()
					return nil
				end)
				local navigationContainer = createPersistenceEnabledContainer(loadNavigationState, persistNavigationState)

				-- jest.runOnlyPendingTimers()
				navigationContainer:dispatch(
					NavigationActions.navigate({ routeName = "baz" })
				)

				-- jest.runOnlyPendingTimers()
				waitUntil(function()
					return warningFound
				end)
				connection:Disconnect()

				jestExpect(warningFound).toEqual(true)
			end)

			it("when loadNavigationState rejects, navigator ignores the rejection and starts from the initial state", function()
				local loadNavigationState = createSpy(function()
					error("loadNavigationState failed")
				end)
				local navigationContainer = createPersistenceEnabledContainer(loadNavigationState)

				jestExpect(loadNavigationState.callCount).never.toEqual(0)
				-- jest.runOnlyPendingTimers()
				jestExpect(navigationContainer.state.nav).toMatchObject({
					index = 1,
					isTransitioning = false,
					key = "StackRouterRoot",
					routes = {{ routeName = "foo" }}
				})
			end)

			-- deviation: Roact does not have componendDidCatch which is used
			-- to implement that feature upstream
			itSKIP(
				"when loadNavigationState resolves with an invalid nav state object, navigator starts from the initial state",
				function()
					local loadNavigationState = createSpy(function()
						return {
							index = 20,
							routes = {
								{ routeName = "foo" },
								{ routeName = "bar" },
							},
						}
					end)
					local navigationContainer = createPersistenceEnabledContainer(loadNavigationState)

					jestExpect(loadNavigationState.callCount).never.toEqual(0)
					-- jest.runOnlyPendingTimers()
					jestExpect(navigationContainer.state.nav).toMatchObject({
						index = 1,
						isTransitioning = false,
						key = "StackRouterRoot",
						routes = {{ routeName = "foo" }},
					})
				end
			)

			it("throws when persistNavigationState and loadNavigationState do not pass validation", function()
				local NavigationContainer = createAppContainer(Stack)

				jestExpect(function()
					Roact.mount(Roact.createElement(NavigationContainer, {
						persistNavigationState = function() end,
					}))
				end).toThrow("both persistNavigationState and loadNavigationState must either be undefined, or be functions")
			end)
		end)
	end)
end
