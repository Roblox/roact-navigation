local LogService = game:GetService("LogService")

return function()
	local root = script.Parent.Parent
	local Packages = root.Parent
	local Roact = require(Packages.Roact)
	local NavigationActions = require(root.NavigationActions)
	local createNavigator = require(root.navigators.createNavigator)
	local createAppContainer = require(root.createAppContainer)
	local StackRouter = require(root.routers.StackRouter)
	local SwitchView = require(root.views.SwitchView.SwitchView)
	local createSpy = require(root.utils.createSpy)
	local waitUntil = require(root.utils.waitUntil)

	local function createStackNavigator(routeConfigMap, stackConfig)
		local router = StackRouter(routeConfigMap, stackConfig)
		return createAppContainer(createNavigator(SwitchView, router, stackConfig))
	end

	describe("NavigationContainer", function()
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

				expect(navigationContainer.state.nav.index).to.equal(1)
				expect(navigationContainer.state.nav.routes).to.be.a("table")
				expect(#navigationContainer.state.nav.routes).to.equal(1)
				expect(navigationContainer.state.nav.routes[1].routeName).to.equal("foo")
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

				expect(
					navigationContainer:dispatch(
						NavigationActions.navigate({ routeName = "bar" })
					)
				).to.equal(true)
			end)

			it("returns false when given an invalid action", function()
				local navigationContainer = nil
				local NavigationContainer = createTestableNavigationContainer(function(value)
					navigationContainer = value
				end)

				Roact.mount(Roact.createElement(NavigationContainer))

				-- jest.runOnlyPendingTimers()
				expect(navigationContainer:dispatch(NavigationActions.back())).to.equal(false)
			end)

			it("updates state.nav with an action by the next tick", function()
				local navigationContainer = nil
				local NavigationContainer = createTestableNavigationContainer(function(value)
					navigationContainer = value
				end)

				Roact.mount(Roact.createElement(NavigationContainer))

				expect(
					navigationContainer:dispatch(
						NavigationActions.navigate({ routeName = "bar" })
					)
				).to.equal(true)

				-- Fake the passing of a tick
				-- jest.runOnlyPendingTimers()

				expect(navigationContainer.state.nav.index).to.equal(2)
				expect(navigationContainer.state.nav.routes[1].routeName).to.equal("foo")
				expect(navigationContainer.state.nav.routes[2].routeName).to.equal("bar")
			end)

			it("does not discard actions when called twice in one tick", function()
				local navigationContainer = nil
				local NavigationContainer = createTestableNavigationContainer(function(value)
					navigationContainer = value
				end)
				Roact.mount(Roact.createElement(NavigationContainer))

				-- First dispatch
				expect(
					navigationContainer:dispatch(
						NavigationActions.navigate({ routeName = "bar" })
					)
				).to.equal(true)

				-- Make sure that the test runner has NOT synchronously applied setState before the tick
				-- expect(navigationContainer.state.nav).toMatchObject(initialState)

				-- Second dispatch
				expect(
					navigationContainer:dispatch(
						NavigationActions.navigate({ routeName = "baz" })
					)
				).to.equal(true)

				-- Fake the passing of a tick
				-- jest.runOnlyPendingTimers()

				expect(navigationContainer.state.nav.index).to.equal(3)
				expect(navigationContainer.state.nav.routes[1].routeName).to.equal("foo")
				expect(navigationContainer.state.nav.routes[2].routeName).to.equal("bar")
				expect(navigationContainer.state.nav.routes[3].routeName).to.equal("baz")
			end)

			it("does not discard actions when called more than 2 times in one tick", function()
				local navigationContainer = nil
				local NavigationContainer = createTestableNavigationContainer(function(value)
					navigationContainer = value
				end)
				Roact.mount(Roact.createElement(NavigationContainer))

				-- First dispatch
				expect(
					navigationContainer:dispatch(
						NavigationActions.navigate({ routeName = "bar" })
					)
				).to.equal(true)

				-- Make sure that the test runner has NOT synchronously applied setState before the tick
				-- expect(navigationContainer.state.nav).toMatchObject(initialState);

				-- Second dispatch
				expect(
					navigationContainer:dispatch(
						NavigationActions.navigate({ routeName = "baz" })
					)
				).to.equal(true)

				-- Third dispatch
				expect(
					navigationContainer:dispatch(
						NavigationActions.navigate({ routeName = "car" })
					)
				).to.equal(true)

				-- Fourth dispatch
				expect(
					navigationContainer:dispatch(
						NavigationActions.navigate({ routeName = "dog" })
					)
				).to.equal(true)

				-- Fifth dispatch
				expect(
					navigationContainer:dispatch(
						NavigationActions.navigate({ routeName = "elk" })
					)
				).to.equal(true)

				-- Fake the passing of a tick
				-- jest.runOnlyPendingTimers()

				expect(navigationContainer.state.nav.index).to.equal(6)
				expect(navigationContainer.state.nav.routes[1].routeName).to.equal("foo")
				expect(navigationContainer.state.nav.routes[2].routeName).to.equal("bar")
				expect(navigationContainer.state.nav.routes[3].routeName).to.equal("baz")
				expect(navigationContainer.state.nav.routes[4].routeName).to.equal("car")
				expect(navigationContainer.state.nav.routes[5].routeName).to.equal("dog")
				expect(navigationContainer.state.nav.routes[6].routeName).to.equal("elk")
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

				expect(loadNavigationState.callCount).never.to.equal(0)
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

				expect(warningFound).to.equal(true)
			end)

			it("when loadNavigationState rejects, navigator ignores the rejection and starts from the initial state", function()
				local loadNavigationState = createSpy(function()
					error("loadNavigationState failed")
				end)
				local navigationContainer = createPersistenceEnabledContainer(loadNavigationState)

				expect(loadNavigationState.callCount).never.to.equal(0)
				-- jest.runOnlyPendingTimers()
				expect(navigationContainer.state.nav.index).to.equal(1)
				expect(navigationContainer.state.nav.isTransitioning).to.equal(false)
				expect(navigationContainer.state.nav.key).to.equal("StackRouterRoot")
				expect(navigationContainer.state.nav.routes[1].routeName).to.equal("foo")
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

					expect(loadNavigationState.callCount).never.to.equal(0)
					-- jest.runOnlyPendingTimers()
					expect(navigationContainer.state.nav.index).to.equal(1)
					expect(navigationContainer.state.nav.isTransitioning).to.equal(false)
					expect(navigationContainer.state.nav.key).to.equal("StackRouterRoot")
					expect(navigationContainer.state.nav.routes[1].routeName).to.equal("foo")
				end
			)

			it("throws when persistNavigationState and loadNavigationState do not pass validation", function()
				local NavigationContainer = createAppContainer(Stack)

				expect(function()
					Roact.mount(Roact.createElement(NavigationContainer, {
						persistNavigationState = function() end,
					}))
				end).to.throw("both persistNavigationState and loadNavigationState must either be undefined, or be functions")
			end)
		end)
	end)
end
