-- upstream https://github.com/react-navigation/react-navigation/blob/20e2625f351f90fadadbf98890270e43e744225b/packages/core/src/views/__tests__/NavigationEvents.test.js

return function()
	local root = script.Parent.Parent.Parent
	local Packages = root.Parent
	local LuauPolyfill = require(Packages.LuauPolyfill)
	local Array = LuauPolyfill.Array
	local Object = LuauPolyfill.Object
	local React = require(Packages.React)
	local ReactRoblox = require(Packages.Dev.ReactRoblox)
	local JestGlobals = require(Packages.Dev.JestGlobals)
	local expect = JestGlobals.expect
	local jest = JestGlobals.jest

	local NavigationEvents = require(script.Parent.Parent.NavigationEvents)
	local NavigationContext = require(root.views.NavigationContext)
	local Events = require(root.Events)

	local function createPropListener()
		return jest.fn()
	end

	local EVENT_TO_PROP_NAME = {
		[Events.WillFocus] = "onWillFocus",
		[Events.DidFocus] = "onDidFocus",
		[Events.WillBlur] = "onWillBlur",
		[Events.DidBlur] = "onDidBlur",
	}

	local function createEventListenersProp()
		local onWillFocus, onWillFocusFn = createPropListener()
		local onDidFocus, onDidFocusFn = createPropListener()
		local onWillBlur, onWillBlurFn = createPropListener()
		local onDidBlur, onDidBlurFn = createPropListener()
		return {
			onWillFocus = onWillFocus,
			onDidFocus = onDidFocus,
			onWillBlur = onWillBlur,
			onDidBlur = onDidBlur,
		}, {
			onWillFocus = onWillFocusFn,
			onDidFocus = onDidFocusFn,
			onWillBlur = onWillBlurFn,
			onDidBlur = onDidBlurFn,
		}
	end

	local function createTestNavigationAndHelpers()
		local NavigationListenersAPI = (function()
			local listeners = {
				[Events.WillFocus] = {},
				[Events.DidFocus] = {},
				[Events.WillBlur] = {},
				[Events.DidBlur] = {},
			}

			return {
				add = function(eventName, handler)
					table.insert(listeners[eventName], handler)
				end,
				remove = function(eventName, handler)
					listeners[eventName] = Array.filter(listeners[eventName], function(current)
						return current ~= handler
					end)
				end,
				get = function(eventName)
					return listeners[eventName]
				end,
				call = function(eventName)
					for _, listener in ipairs(listeners[eventName]) do
						listener()
					end
				end,
			}
		end)()

		local navigation = {
			addListener = jest.fn(function(eventName, handler)
				NavigationListenersAPI.add(eventName, handler)

				return {
					remove = function()
						return NavigationListenersAPI.remove(eventName, handler)
					end,
				}
			end),
		}

		return {
			navigation = navigation,
			NavigationListenersAPI = NavigationListenersAPI,
		}
	end

	describe("NavigationEvents", function()
		it(
			"add all listeners on mount and remove them on unmount, even without any event prop provided (see #5058)",
			function()
				local helper = createTestNavigationAndHelpers()
				local navigation = helper.navigation
				local NavigationListenersAPI = helper.NavigationListenersAPI

				local root = ReactRoblox.createRoot(Instance.new("Folder"))
				ReactRoblox.act(function()
					root:render(React.createElement(NavigationEvents, { navigation = navigation }))
				end)

				expect(#NavigationListenersAPI.get(Events.WillFocus)).toBe(1)
				expect(#NavigationListenersAPI.get(Events.DidFocus)).toBe(1)
				expect(#NavigationListenersAPI.get(Events.WillBlur)).toBe(1)
				expect(#NavigationListenersAPI.get(Events.DidBlur)).toBe(1)

				ReactRoblox.act(function()
					root:unmount()
				end)
				expect(#NavigationListenersAPI.get(Events.WillFocus)).toBe(0)
				expect(#NavigationListenersAPI.get(Events.DidFocus)).toBe(0)
				expect(#NavigationListenersAPI.get(Events.WillBlur)).toBe(0)
				expect(#NavigationListenersAPI.get(Events.DidBlur)).toBe(0)
			end
		)

		it("support context-provided navigation", function()
			local helper = createTestNavigationAndHelpers()
			local navigation = helper.navigation
			local NavigationListenersAPI = helper.NavigationListenersAPI

			local root = ReactRoblox.createRoot(Instance.new("Folder"))
			ReactRoblox.act(function()
				root:render(React.createElement(NavigationContext.Provider, {
					value = navigation,
				}, React.createElement(NavigationEvents)))
			end)

			expect(#NavigationListenersAPI.get(Events.WillFocus)).toBe(1)
			expect(#NavigationListenersAPI.get(Events.DidFocus)).toBe(1)
			expect(#NavigationListenersAPI.get(Events.WillBlur)).toBe(1)
			expect(#NavigationListenersAPI.get(Events.DidBlur)).toBe(1)

			ReactRoblox.act(function()
				root:unmount()
			end)
			expect(#NavigationListenersAPI.get(Events.WillFocus)).toBe(0)
			expect(#NavigationListenersAPI.get(Events.DidFocus)).toBe(0)
			expect(#NavigationListenersAPI.get(Events.WillBlur)).toBe(0)
			expect(#NavigationListenersAPI.get(Events.DidBlur)).toBe(0)
		end)

		it("wire props listeners to navigation listeners", function()
			local helper = createTestNavigationAndHelpers()
			local navigation = helper.navigation
			local NavigationListenersAPI = helper.NavigationListenersAPI

			local eventListenerProps, eventListenerPropsFn = createEventListenersProp()

			local root = ReactRoblox.createRoot(Instance.new("Folder"))
			ReactRoblox.act(function()
				root:render(
					React.createElement(
						NavigationEvents,
						Object.assign({ navigation = navigation }, eventListenerPropsFn)
					)
				)
			end)

			local function checkPropListenerIsCalled(eventName, propName)
				expect(eventListenerProps[propName]).toHaveBeenCalledTimes(0)
				NavigationListenersAPI.call(eventName)
				expect(eventListenerProps[propName]).toHaveBeenCalledTimes(1)
			end

			checkPropListenerIsCalled(Events.WillFocus, "onWillFocus")
			checkPropListenerIsCalled(Events.DidFocus, "onDidFocus")
			checkPropListenerIsCalled(Events.WillBlur, "onWillBlur")
			checkPropListenerIsCalled(Events.DidBlur, "onDidBlur")
		end)

		it("wires props listeners to latest navigation updates", function()
			local helper = createTestNavigationAndHelpers()
			local navigation = helper.navigation
			local NavigationListenersAPI = helper.NavigationListenersAPI
			local nextHelper = createTestNavigationAndHelpers()
			local nextNavigation = nextHelper.navigation
			local nextNavigationListenersAPI = nextHelper.NavigationListenersAPI

			local eventListenerProps, eventListenerPropsFn = createEventListenersProp()

			local root = ReactRoblox.createRoot(Instance.new("Folder"))
			ReactRoblox.act(function()
				root:render(
					React.createElement(
						NavigationEvents,
						Object.assign({ navigation = navigation }, eventListenerPropsFn)
					)
				)
			end)

			for eventName, propName in pairs(EVENT_TO_PROP_NAME) do
				expect(eventListenerProps[propName]).toHaveBeenCalledTimes(0)
				ReactRoblox.act(function()
					NavigationListenersAPI.call(eventName)
				end)
				expect(eventListenerProps[propName]).toHaveBeenCalledTimes(1)
			end

			ReactRoblox.act(function()
				root:render(
					React.createElement(
						NavigationEvents,
						Object.assign({ navigation = nextNavigation }, eventListenerProps)
					)
				)
			end)

			for eventName, propName in pairs(EVENT_TO_PROP_NAME) do
				ReactRoblox.act(function()
					NavigationListenersAPI.call(eventName)
				end)
				expect(eventListenerProps[propName]).toHaveBeenCalledTimes(1)
				ReactRoblox.act(function()
					nextNavigationListenersAPI.call(eventName)
				end)
				expect(eventListenerProps[propName]).toHaveBeenCalledTimes(2)
			end
		end)

		it(
			"wire latest props listener to navigation listeners on updates (support closure/arrow functions update)",
			function()
				local helper = createTestNavigationAndHelpers()
				local navigation = helper.navigation
				local NavigationListenersAPI = helper.NavigationListenersAPI

				local root = ReactRoblox.createRoot(Instance.new("Folder"))
				ReactRoblox.act(function()
					root:render(
						React.createElement(
							NavigationEvents,
							Object.assign({ navigation = navigation }, select(2, createEventListenersProp()))
						)
					)
				end)

				ReactRoblox.act(function()
					root:render(React.createElement(NavigationEvents, {
						navigation = navigation,
						onWillBlur = function()
							error("should not be called")
						end,
						onDidFocus = function()
							error("should not be called")
						end,
					}))
				end)
				ReactRoblox.act(function()
					root:render(
						React.createElement(
							NavigationEvents,
							Object.assign({ navigation = navigation }, select(2, createEventListenersProp()))
						)
					)
				end)

				local latestEventListenerProps, latestEventListenerPropsFn = createEventListenersProp()

				ReactRoblox.act(function()
					root:render(
						React.createElement(
							NavigationEvents,
							Object.assign({ navigation = navigation }, latestEventListenerPropsFn)
						)
					)
				end)

				local function checkLatestPropListenerCalled(eventName, propName)
					expect(latestEventListenerProps[propName]).toHaveBeenCalledTimes(0)
					NavigationListenersAPI.call(eventName)
					expect(latestEventListenerProps[propName]).toHaveBeenCalledTimes(1)
				end

				checkLatestPropListenerCalled(Events.WillFocus, "onWillFocus")
				checkLatestPropListenerCalled(Events.DidFocus, "onDidFocus")
				checkLatestPropListenerCalled(Events.WillBlur, "onWillBlur")
				checkLatestPropListenerCalled(Events.DidBlur, "onDidBlur")
			end
		)
	end)
end
