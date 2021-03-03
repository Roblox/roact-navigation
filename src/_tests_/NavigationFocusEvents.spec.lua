-- upstream https://github.com/react-navigation/react-navigation/blob/9b55493e7662f4d54c21f75e53eb3911675f61bc/packages/core/src/__tests__/NavigationFocusEvents.test.js
return function()
	local RoactNavigationModule = script.Parent.Parent
	local Packages = RoactNavigationModule.Parent

	local TabRouter = require(RoactNavigationModule.routers.TabRouter)
	local createAppContainer = require(RoactNavigationModule.createAppContainer)
	local createNavigator = require(RoactNavigationModule.navigators.createNavigator)
	local Events = require(RoactNavigationModule.Events)
	local NavigationActions = require(RoactNavigationModule.NavigationActions)
	local createSpy = require(RoactNavigationModule.utils.createSpy)
	local waitUntil = require(RoactNavigationModule.utils.waitUntil)

	local jestExpect = require(Packages.Dev.JestRoblox).Globals.expect
	local Cryo = require(Packages.Cryo)
	local Roact = require(Packages.Roact)

	-- deviation: utility function moved out of test scope because
	-- it is shared across both tests
	local function createTestNavigator(routeConfigMap, config)
		config = config or {}
		local router = TabRouter(routeConfigMap, config)

		return createNavigator(
			function(props)
				local navigation = props.navigation
				local descriptors = props.descriptors

				local children = Cryo.List.foldLeft(navigation.state.routes, function(acc, route)
					local Comp = descriptors[route.key].getComponent()
					acc[route.key] = Roact.createElement(Comp, {
						key = route.key,
						navigation = descriptors[route.key].navigation
					})
					return acc
				end, {})

				return Roact.createFragment(children)
			end,
			router,
			config
		)
	end

	-- deviation: utility function moved out of test scope because
	-- it is shared across both tests
	local function createComponent(focusCallback, blurCallback)
		local TestComponent = Roact.Component:extend("TestComponent")

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

	it("fires focus and blur events in root navigator", function()
		local firstFocusCallback = createSpy()
		local firstBlurCallback = createSpy()

		local secondFocusCallback = createSpy()
		local secondBlurCallback = createSpy()

		local thirdFocusCallback = createSpy()
		local thirdBlurCallback = createSpy()

		local fourthFocusCallback = createSpy()
		local fourthBlurCallback = createSpy()

		local Navigator = createAppContainer(
			createTestNavigator({
				{ first = createComponent(firstFocusCallback.value, firstBlurCallback.value) },
				{ second = createComponent(secondFocusCallback.value, secondBlurCallback.value) },
				{ third = createComponent(thirdFocusCallback.value, thirdBlurCallback.value) },
				{ fourth = createComponent(fourthFocusCallback.value, fourthBlurCallback.value) },
			})
		)

		local dispatch
		local element = Roact.createElement(Navigator, {
			externalDispatchConnector = function(currentDispatch)
				dispatch = currentDispatch
				return function ()
					dispatch = nil
				end
			end
		})

		Roact.mount(element)

		waitUntil(function()
			return firstFocusCallback.callCount > 0
		end)

		jestExpect(firstFocusCallback.callCount).toEqual(1)
		jestExpect(firstBlurCallback.callCount).toEqual(0)
		jestExpect(secondFocusCallback.callCount).toEqual(0)
		jestExpect(secondBlurCallback.callCount).toEqual(0)
		jestExpect(thirdFocusCallback.callCount).toEqual(0)
		jestExpect(thirdBlurCallback.callCount).toEqual(0)
		jestExpect(fourthFocusCallback.callCount).toEqual(0)
		jestExpect(fourthBlurCallback.callCount).toEqual(0)

		dispatch(NavigationActions.navigate({ routeName = 'second' }))

		waitUntil(function()
			return firstBlurCallback.callCount > 0
		end)

		jestExpect(firstBlurCallback.callCount).toEqual(1)
		jestExpect(secondFocusCallback.callCount).toEqual(1)

		dispatch(NavigationActions.navigate({ routeName = 'fourth' }))

		waitUntil(function()
			return secondBlurCallback.callCount > 0
		end)

		jestExpect(firstFocusCallback.callCount).toEqual(1)
		jestExpect(firstBlurCallback.callCount).toEqual(1)
		jestExpect(secondFocusCallback.callCount).toEqual(1)
		jestExpect(secondBlurCallback.callCount).toEqual(1)
		jestExpect(thirdFocusCallback.callCount).toEqual(0)
		jestExpect(thirdBlurCallback.callCount).toEqual(0)
		jestExpect(fourthFocusCallback.callCount).toEqual(1)
		jestExpect(fourthBlurCallback.callCount).toEqual(0)
	end)

	it('fires focus and blur events in nested navigator', function()
		local firstFocusCallback = createSpy()
		local firstBlurCallback = createSpy()

		local secondFocusCallback = createSpy()
		local secondBlurCallback = createSpy()

		local thirdFocusCallback = createSpy()
		local thirdBlurCallback = createSpy()

		local fourthFocusCallback = createSpy()
		local fourthBlurCallback = createSpy()

		local Navigator = createAppContainer(
			createTestNavigator({
				{ first = createComponent(firstFocusCallback.value, firstBlurCallback.value) },
				{ second = createComponent(secondFocusCallback.value, secondBlurCallback.value) },
				{
					nested = createTestNavigator({
						{ third = createComponent(thirdFocusCallback.value, thirdBlurCallback.value) },
						{ fourth = createComponent(fourthFocusCallback.value, fourthBlurCallback.value) },
					})
				},
			})
		)

		local dispatch
		local element = Roact.createElement(Navigator, {
			externalDispatchConnector = function(currentDispatch)
				dispatch = currentDispatch
				return function ()
					dispatch = nil
				end
			end
		})

		Roact.mount(element)

		waitUntil(function()
			return firstFocusCallback.callCount > 0
		end)

		jestExpect(thirdFocusCallback.callCount).toEqual(0)
		jestExpect(firstFocusCallback.callCount).toEqual(1)

		dispatch(NavigationActions.navigate({ routeName = 'nested' }))

		waitUntil(function()
			return thirdFocusCallback.callCount > 0
		end)

		jestExpect(firstFocusCallback.callCount).toEqual(1)
		jestExpect(fourthFocusCallback.callCount).toEqual(0)
		jestExpect(thirdFocusCallback.callCount).toEqual(1)

		dispatch(NavigationActions.navigate({ routeName = 'second' }))

		waitUntil(function()
			return secondFocusCallback.callCount > 0
		end)

		jestExpect(thirdFocusCallback.callCount).toEqual(1)
		jestExpect(secondFocusCallback.callCount).toEqual(1)
		jestExpect(fourthBlurCallback.callCount).toEqual(0)

		dispatch(NavigationActions.navigate({ routeName = 'nested' }))

		waitUntil(function()
			return thirdFocusCallback.callCount > 1
		end)

		jestExpect(firstBlurCallback.callCount).toEqual(1)
		jestExpect(secondBlurCallback.callCount).toEqual(1)
		jestExpect(thirdFocusCallback.callCount).toEqual(2)
		jestExpect(fourthFocusCallback.callCount).toEqual(0)

		dispatch(NavigationActions.navigate({ routeName = 'third' }))

		jestExpect(fourthBlurCallback.callCount).toEqual(0)
		jestExpect(thirdFocusCallback.callCount).toEqual(2)

		dispatch(NavigationActions.navigate({ routeName = 'first' }))

		waitUntil(function()
			return firstFocusCallback.callCount > 1
		end)

		jestExpect(firstFocusCallback.callCount).toEqual(2)
		jestExpect(thirdBlurCallback.callCount).toEqual(2)

		dispatch(NavigationActions.navigate({ routeName = 'fourth' }))

		waitUntil(function()
			return fourthFocusCallback.callCount > 0
		end)

		jestExpect(fourthFocusCallback.callCount).toEqual(1)
		jestExpect(thirdBlurCallback.callCount).toEqual(2)
		jestExpect(firstBlurCallback.callCount).toEqual(2)

		dispatch(NavigationActions.navigate({ routeName = 'third' }))

		waitUntil(function()
			return thirdFocusCallback.callCount > 2
		end)

		jestExpect(thirdFocusCallback.callCount).toEqual(3)
		jestExpect(fourthBlurCallback.callCount).toEqual(1)

		-- Make sure nothing else has changed
		jestExpect(firstFocusCallback.callCount).toEqual(2)
		jestExpect(firstBlurCallback.callCount).toEqual(2)

		jestExpect(secondFocusCallback.callCount).toEqual(1)
		jestExpect(secondBlurCallback.callCount).toEqual(1)

		jestExpect(thirdFocusCallback.callCount).toEqual(3)
		jestExpect(thirdBlurCallback.callCount).toEqual(2)

		jestExpect(fourthFocusCallback.callCount).toEqual(1)
		jestExpect(fourthBlurCallback.callCount).toEqual(1)
	end)
end
