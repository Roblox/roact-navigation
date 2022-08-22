-- upstream https://github.com/react-navigation/react-navigation/blob/9b55493e7662f4d54c21f75e53eb3911675f61bc/packages/core/src/views/__tests__/NavigationFocusEvents.test.js

return function()
	local viewsModule = script.Parent.Parent
	local RoactNavigationModule = viewsModule.Parent
	local Packages = RoactNavigationModule.Parent
	local Cryo = require(Packages.Cryo)
	local Roact = require(Packages.Roact)
	local JestGlobals = require(Packages.Dev.JestGlobals)
	local expect = JestGlobals.expect
	local jest = JestGlobals.jest

	local NavigationFocusEvents = require(viewsModule.NavigationFocusEvents)
	local getEventManager = require(RoactNavigationModule.getEventManager)
	local NavigationActions = require(RoactNavigationModule.NavigationActions)
	local StackActions = require(RoactNavigationModule.routers.StackActions)
	local Events = require(RoactNavigationModule.Events)

	local function getNavigationMock(mock)
		local eventManager = getEventManager("target")

		local default = {
			state = {
				routes = {
					{ key = "a", routeName = "foo" },
					{ key = "b", routeName = "bar" },
				},
				index = 1,
			},
			isFocused = function()
				return true
			end,
			addListener = jest.fn(eventManager.addListener),
			emit = eventManager.emit,
			_dangerouslyGetParent = function()
				return nil
			end,
		}

		if mock then
			return Cryo.Dictionary.join(default, mock)
		end

		return default
	end

	it("emits refocus event with current route key on refocus", function()
		local navigation = getNavigationMock()
		local onEvent, onEventFn = jest.fn()

		Roact.mount(Roact.createElement(NavigationFocusEvents, {
			navigation = navigation,
			onEvent = onEventFn,
		}))

		navigation.emit(Events.Refocus)

		expect(onEvent).toHaveBeenCalledTimes(1)
		local key = navigation.state.routes[navigation.state.index].key
		expect(onEvent).toHaveBeenCalledWith(key, Events.Refocus)
	end)

	describe("on navigation action emitted", function()
		it("does not emit if navigation is not focused", function()
			local navigation = getNavigationMock({
				isFocused = function()
					return false
				end,
			})
			local onEvent, onEventFn = jest.fn()

			Roact.mount(Roact.createElement(NavigationFocusEvents, {
				navigation = navigation,
				onEvent = onEventFn,
			}))

			navigation.emit(Events.Action, {
				state = navigation.state,
				action = NavigationActions.init(),
				type = Events.Action,
			})

			expect(onEvent).never.toHaveBeenCalled()
		end)

		it("emits only willFocus and willBlur if state is transitioning", function()
			local state = {
				routes = {
					{ key = "First", routeName = "First" },
					{ key = "Second", routeName = "Second" },
				},
				index = 2,
				routeKeyHistory = { "First", "Second" },
				isTransitioning = true,
			}
			local action = NavigationActions.init()

			local navigation = getNavigationMock({
				state = state,
			})
			local onEvent, onEventFn = jest.fn()

			Roact.mount(Roact.createElement(NavigationFocusEvents, {
				navigation = navigation,
				onEvent = onEventFn,
			}))

			local lastState = {
				routes = {
					{ key = "First", routeName = "First" },
					{ key = "Second", routeName = "Second" },
				},
				index = 1,
				routeKeyHistory = { "First" },
			}
			navigation.emit(Events.Action, {
				state = state,
				lastState = lastState,
				action = action,
				type = Events.Action,
			})

			local expectedPayload = {
				action = action,
				state = { key = "Second", routeName = "Second" },
				lastState = { key = "First", routeName = "First" },
				context = "Second:INIT_Root",
				type = Events.Action,
			}

			expect(onEvent.mock.calls).toEqual({
				{ "Second", Events.WillFocus, expectedPayload },
				{ "First", Events.WillBlur, expectedPayload },
				{ "Second", Events.Action, expectedPayload },
			})
		end)

		it("emits didFocus after willFocus and didBlur after willBlur if no transitions", function()
			local state = {
				routes = {
					{ key = "First", routeName = "First" },
					{ key = "Second", routeName = "Second" },
				},
				index = 2,
				routeKeyHistory = { "First", "Second" },
			}
			local action = NavigationActions.navigate({ routeName = "Second" })

			local navigation = getNavigationMock({ state = state })
			local onEvent, onEventFn = jest.fn()

			Roact.mount(Roact.createElement(NavigationFocusEvents, {
				navigation = navigation,
				onEvent = onEventFn,
			}))

			local lastState = {
				routes = {
					{ key = "First", routeName = "First" },
					{ key = "Second", routeName = "Second" },
				},
				index = 1,
				routeKeyHistory = { "First" },
			}
			navigation.emit(Events.Action, {
				state = state,
				lastState = lastState,
				action = action,
				type = Events.Action,
			})

			local expectedPayload = {
				action = action,
				state = { key = "Second", routeName = "Second" },
				lastState = { key = "First", routeName = "First" },
				context = "Second:NAVIGATE_Root",
				type = Events.Action,
			}

			expect(onEvent.mock.calls).toEqual({
				{ "Second", Events.WillFocus, expectedPayload },
				{ "Second", Events.DidFocus, expectedPayload },
				{ "First", Events.WillBlur, expectedPayload },
				{ "First", Events.DidBlur, expectedPayload },
				{ "Second", Events.Action, expectedPayload },
			})
		end)

		it("emits didBlur and didFocus when transition ends", function()
			local initialState = {
				routes = {
					{ key = "First", routeName = "First" },
					{ key = "Second", routeName = "Second" },
				},
				index = 1,
				routeKeyHistory = { "First" },
				isTransitioning = true,
			}
			local intermediateState = {
				routes = {
					{ key = "First", routeName = "First" },
					{ key = "Second", routeName = "Second" },
				},
				index = 2,
				routeKeyHistory = { "First", "Second" },
				isTransitioning = true,
			}
			local finalState = {
				routes = {
					{ key = "First", routeName = "First" },
					{ key = "Second", routeName = "Second" },
				},
				index = 2,
				routeKeyHistory = { "First", "Second" },
				isTransitioning = false,
			}
			local actionNavigate = NavigationActions.navigate({ routeName = "Second" })
			local actionEndTransition = StackActions.completeTransition({ key = "Second" })

			local navigation = getNavigationMock({
				state = intermediateState,
			})
			local onEvent, onEventFn = jest.fn()

			Roact.mount(Roact.createElement(NavigationFocusEvents, {
				navigation = navigation,
				onEvent = onEventFn,
			}))

			navigation.emit(Events.Action, {
				state = intermediateState,
				lastState = initialState,
				action = actionNavigate,
				type = Events.Action,
			})

			local expectedPayloadNavigate = {
				action = actionNavigate,
				state = { key = "Second", routeName = "Second" },
				lastState = { key = "First", routeName = "First" },
				context = "Second:NAVIGATE_Root",
				type = Events.Action,
			}

			expect(onEvent.mock.calls).toEqual({
				{ "Second", Events.WillFocus, expectedPayloadNavigate },
				{ "First", Events.WillBlur, expectedPayloadNavigate },
				{ "Second", Events.Action, expectedPayloadNavigate },
			})
			onEvent:mockClear()

			navigation.emit(Events.Action, {
				state = finalState,
				lastState = intermediateState,
				action = actionEndTransition,
				type = Events.Action,
			})

			local expectedPayloadEndTransition = {
				action = actionEndTransition,
				state = { key = "Second", routeName = "Second" },
				lastState = { key = "Second", routeName = "Second" },
				context = "Second:COMPLETE_TRANSITION_Root",
				type = Events.Action,
			}

			expect(onEvent.mock.calls).toEqual({
				{ "First", Events.DidBlur, expectedPayloadEndTransition },
				{ "Second", Events.DidFocus, expectedPayloadEndTransition },
				{ "Second", Events.Action, expectedPayloadEndTransition },
			})
		end)
	end)

	describe("on willFocus emitted", function()
		it("emits didFocus after willFocus if no transition", function()
			local navigation = getNavigationMock({
				state = {
					routes = {
						{ key = "FirstLanding", routeName = "FirstLanding" },
						{ key = "Second", routeName = "Second" },
					},
					index = 1,
					key = "First",
					routeName = "First",
				},
			})
			local onEvent, onEventFn = jest.fn()

			Roact.mount(Roact.createElement(NavigationFocusEvents, {
				navigation = navigation,
				onEvent = onEventFn,
			}))

			local lastState = { key = "Third", routeName = "Third" }
			local action = NavigationActions.navigate({ routeName = "First" })

			navigation.emit(Events.WillFocus, {
				lastState = lastState,
				action = action,
				context = "First:NAVIGATE_Root",
				type = Events.Action,
			})

			local expectedPayload = {
				action = action,
				state = { key = "FirstLanding", routeName = "FirstLanding" },
				context = "FirstLanding:NAVIGATE_First:NAVIGATE_Root",
				type = Events.Action,
			}

			expect(onEvent.mock.calls).toEqual({
				{ "FirstLanding", Events.WillFocus, expectedPayload },
				{ "FirstLanding", Events.DidFocus, expectedPayload },
			})

			onEvent:mockClear()

			-- the nested navigator might emit a didFocus that should be ignored
			navigation.emit(Events.DidFocus, {
				lastState = lastState,
				action = action,
				context = "First:NAVIGATE_Root",
				type = Events.Action,
			})

			expect(onEvent).never.toHaveBeenCalled()
		end)
	end)
end
