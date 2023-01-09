-- upstream https://github.com/react-navigation/react-navigation/blob/9b55493e7662f4d54c21f75e53eb3911675f61bc/packages/core/src/__tests__/NavigationFocusEvents.test.js
return function()
	local RoactNavigationModule = script.Parent.Parent
	local Packages = RoactNavigationModule.Parent

	local TabRouter = require(RoactNavigationModule.routers.TabRouter)
	local createAppContainerExports = require(RoactNavigationModule.createAppContainer)
	local createAppContainer = createAppContainerExports.createAppContainer
	local _TESTING_ONLY_reset_container_count = createAppContainerExports._TESTING_ONLY_reset_container_count
	local createNavigator = require(RoactNavigationModule.navigators.createNavigator)
	local Events = require(RoactNavigationModule.Events)
	local NavigationActions = require(RoactNavigationModule.NavigationActions)
	local waitUntil = require(RoactNavigationModule.utils.waitUntil)

	local JestGlobals = require(Packages.Dev.JestGlobals)
	local expect = JestGlobals.expect
	local jest = JestGlobals.jest
	local LuauPolyfill = require(Packages.LuauPolyfill)
	local Array = LuauPolyfill.Array
	local React = require(Packages.React)
	local ReactRoblox = require(Packages.Dev.ReactRoblox)

	-- deviation: utility function moved out of test scope because
	-- it is shared across both tests
	local function createTestNavigator(routeConfigMap, config)
		config = config or {}
		local router = TabRouter(routeConfigMap, config)

		return createNavigator(function(props)
			local navigation = props.navigation
			local descriptors = props.descriptors

			local children = Array.reduce(navigation.state.routes, function(acc, route)
				local Comp = descriptors[route.key].getComponent()
				acc[route.key] = React.createElement(Comp, {
					key = route.key,
					navigation = descriptors[route.key].navigation,
				})
				return acc
			end, {})

			return React.createElement(React.Fragment, {}, children)
		end, router, config)
	end

	-- deviation: utility function moved out of test scope because
	-- it is shared across both tests
	local function createComponent(focusCallback, blurCallback)
		local TestComponent = React.Component:extend("TestComponent")

		function TestComponent:didMount()
			local navigation = self.props.navigation

			self.focusSub = navigation.addListener(Events.WillFocus, focusCallback)
			self.blurSub = navigation.addListener(Events.WillBlur, blurCallback)
		end

		function TestComponent:willUnmount()
			self.focusSub.remove()
			self.blurSub.remove()
		end

		function TestComponent:render()
			return nil
		end

		return TestComponent
	end

	beforeEach(function()
		_TESTING_ONLY_reset_container_count()
	end)

	it("fires focus and blur events in root navigator", function()
		local firstFocusCallback, firstFocusCallbackFn = jest.fn()
		local firstBlurCallback, firstBlurCallbackFn = jest.fn()

		local secondFocusCallback, secondFocusCallbackFn = jest.fn()
		local secondBlurCallback, secondBlurCallbackFn = jest.fn()

		local thirdFocusCallback, thirdFocusCallbackFn = jest.fn()
		local thirdBlurCallback, thirdBlurCallbackFn = jest.fn()

		local fourthFocusCallback, fourthFocusCallbackFn = jest.fn()
		local fourthBlurCallback, fourthBlurCallbackFn = jest.fn()

		local Navigator = createAppContainer(createTestNavigator({
			{ first = createComponent(firstFocusCallbackFn, firstBlurCallbackFn) },
			{ second = createComponent(secondFocusCallbackFn, secondBlurCallbackFn) },
			{ third = createComponent(thirdFocusCallbackFn, thirdBlurCallbackFn) },
			{ fourth = createComponent(fourthFocusCallbackFn, fourthBlurCallbackFn) },
		}))

		local dispatch
		local element = React.createElement(Navigator, {
			externalDispatchConnector = function(currentDispatch)
				dispatch = currentDispatch
				return function()
					dispatch = nil
				end
			end,
		})

		local parent = Instance.new("Folder")
		local root = ReactRoblox.createRoot(parent)
		ReactRoblox.act(function()
			root:render(element)
		end)

		waitUntil(function()
			return #firstFocusCallback.mock.calls > 0
		end)

		expect(firstFocusCallback).toHaveBeenCalledTimes(1)
		expect(firstBlurCallback).toHaveBeenCalledTimes(0)
		expect(secondFocusCallback).toHaveBeenCalledTimes(0)
		expect(secondBlurCallback).toHaveBeenCalledTimes(0)
		expect(thirdFocusCallback).toHaveBeenCalledTimes(0)
		expect(thirdBlurCallback).toHaveBeenCalledTimes(0)
		expect(fourthFocusCallback).toHaveBeenCalledTimes(0)
		expect(fourthBlurCallback).toHaveBeenCalledTimes(0)

		dispatch(NavigationActions.navigate({ routeName = "second" }))

		waitUntil(function()
			return #firstBlurCallback.mock.calls > 0
		end)

		expect(firstBlurCallback).toHaveBeenCalledTimes(1)
		expect(secondFocusCallback).toHaveBeenCalledTimes(1)

		dispatch(NavigationActions.navigate({ routeName = "fourth" }))

		waitUntil(function()
			return #secondBlurCallback.mock.calls > 0
		end)

		expect(firstFocusCallback).toHaveBeenCalledTimes(1)
		expect(firstBlurCallback).toHaveBeenCalledTimes(1)
		expect(secondFocusCallback).toHaveBeenCalledTimes(1)
		expect(secondBlurCallback).toHaveBeenCalledTimes(1)
		expect(thirdFocusCallback).toHaveBeenCalledTimes(0)
		expect(thirdBlurCallback).toHaveBeenCalledTimes(0)
		expect(fourthFocusCallback).toHaveBeenCalledTimes(1)
		expect(fourthBlurCallback).toHaveBeenCalledTimes(0)
	end)

	it("fires focus and blur events in nested navigator", function()
		local firstFocusCallback, firstFocusCallbackFn = jest.fn()
		local firstBlurCallback, firstBlurCallbackFn = jest.fn()

		local secondFocusCallback, secondFocusCallbackFn = jest.fn()
		local secondBlurCallback, secondBlurCallbackFn = jest.fn()

		local thirdFocusCallback, thirdFocusCallbackFn = jest.fn()
		local thirdBlurCallback, thirdBlurCallbackFn = jest.fn()

		local fourthFocusCallback, fourthFocusCallbackFn = jest.fn()
		local fourthBlurCallback, fourthBlurCallbackFn = jest.fn()

		local Navigator = createAppContainer(createTestNavigator({
			{ first = createComponent(firstFocusCallbackFn, firstBlurCallbackFn) },
			{ second = createComponent(secondFocusCallbackFn, secondBlurCallbackFn) },
			{
				nested = createTestNavigator({
					{ third = createComponent(thirdFocusCallbackFn, thirdBlurCallbackFn) },
					{ fourth = createComponent(fourthFocusCallbackFn, fourthBlurCallbackFn) },
				}),
			},
		}))

		local dispatch
		local element = React.createElement(Navigator, {
			externalDispatchConnector = function(currentDispatch)
				dispatch = currentDispatch
				return function()
					dispatch = nil
				end
			end,
		})

		local parent = Instance.new("Folder")
		local root = ReactRoblox.createRoot(parent)
		ReactRoblox.act(function()
			root:render(element)
		end)

		waitUntil(function()
			return #firstFocusCallback.mock.calls > 0
		end)

		expect(thirdFocusCallback).toHaveBeenCalledTimes(0)
		expect(firstFocusCallback).toHaveBeenCalledTimes(1)

		dispatch(NavigationActions.navigate({ routeName = "nested" }))

		waitUntil(function()
			return #thirdFocusCallback.mock.calls > 0
		end)

		expect(firstFocusCallback).toHaveBeenCalledTimes(1)
		expect(fourthFocusCallback).toHaveBeenCalledTimes(0)
		expect(thirdFocusCallback).toHaveBeenCalledTimes(1)

		dispatch(NavigationActions.navigate({ routeName = "second" }))

		waitUntil(function()
			return #secondFocusCallback.mock.calls > 0
		end)

		expect(thirdFocusCallback).toHaveBeenCalledTimes(1)
		expect(secondFocusCallback).toHaveBeenCalledTimes(1)
		expect(fourthBlurCallback).toHaveBeenCalledTimes(0)

		dispatch(NavigationActions.navigate({ routeName = "nested" }))

		waitUntil(function()
			return #thirdFocusCallback.mock.calls > 1
		end)

		expect(firstBlurCallback).toHaveBeenCalledTimes(1)
		expect(secondBlurCallback).toHaveBeenCalledTimes(1)
		expect(thirdFocusCallback).toHaveBeenCalledTimes(2)
		expect(fourthFocusCallback).toHaveBeenCalledTimes(0)

		dispatch(NavigationActions.navigate({ routeName = "third" }))

		expect(fourthBlurCallback).toHaveBeenCalledTimes(0)
		expect(thirdFocusCallback).toHaveBeenCalledTimes(2)

		dispatch(NavigationActions.navigate({ routeName = "first" }))

		waitUntil(function()
			return #firstFocusCallback.mock.calls > 1
		end)

		expect(firstFocusCallback).toHaveBeenCalledTimes(2)
		expect(thirdBlurCallback).toHaveBeenCalledTimes(2)

		dispatch(NavigationActions.navigate({ routeName = "fourth" }))

		waitUntil(function()
			return #fourthFocusCallback.mock.calls > 0
		end)

		expect(fourthFocusCallback).toHaveBeenCalledTimes(1)
		expect(thirdBlurCallback).toHaveBeenCalledTimes(2)
		expect(firstBlurCallback).toHaveBeenCalledTimes(2)

		dispatch(NavigationActions.navigate({ routeName = "third" }))

		waitUntil(function()
			return #thirdFocusCallback.mock.calls > 2
		end)

		expect(thirdFocusCallback).toHaveBeenCalledTimes(3)
		expect(fourthBlurCallback).toHaveBeenCalledTimes(1)

		-- Make sure nothing else has changed
		expect(firstFocusCallback).toHaveBeenCalledTimes(2)
		expect(firstBlurCallback).toHaveBeenCalledTimes(2)

		expect(secondFocusCallback).toHaveBeenCalledTimes(1)
		expect(secondBlurCallback).toHaveBeenCalledTimes(1)

		expect(thirdFocusCallback).toHaveBeenCalledTimes(3)
		expect(thirdBlurCallback).toHaveBeenCalledTimes(2)

		expect(fourthFocusCallback).toHaveBeenCalledTimes(1)
		expect(fourthBlurCallback).toHaveBeenCalledTimes(1)
	end)
end
