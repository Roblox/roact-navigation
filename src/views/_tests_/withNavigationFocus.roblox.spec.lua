return function()
	local viewsModule = script.Parent.Parent
	local RoactNavigationModule = viewsModule.Parent
	local Packages = RoactNavigationModule.Parent

	local React = require(Packages.React)
	local ReactRoblox = require(Packages.Dev.ReactRoblox)
	local JestGlobals = require(Packages.Dev.JestGlobals)

	local expect = JestGlobals.expect

	local NavigationContext = require(viewsModule.NavigationContext)
	local Events = require(RoactNavigationModule.Events)
	local withNavigationFocus = require(viewsModule.withNavigationFocus)

	it("should pass focused=true when initially focused", function()
		local testFocused = nil

		local function Foo(props)
			testFocused = props.isFocused
			return nil
		end

		local FooWithNavigationFocus = withNavigationFocus(Foo)

		local navigationProp = {
			isFocused = function()
				return true
			end,
			addListener = function()
				return {
					remove = function() end,
				}
			end,
		}

		local rootElement = React.createElement(NavigationContext.Provider, {
			value = navigationProp,
		}, {
			child = React.createElement(FooWithNavigationFocus),
		})

		local root = ReactRoblox.createRoot(Instance.new("Folder"))
		ReactRoblox.act(function()
			root:render(rootElement)
		end)

		expect(testFocused).toEqual(true)

		ReactRoblox.act(function()
			root:unmount()
		end)
	end)

	it("should pass focused=false when initially unfocused", function()
		local testFocused = nil

		local function Foo(props)
			testFocused = props.isFocused
			return nil
		end

		local FooWithNavigationFocus = withNavigationFocus(Foo)

		local navigationProp = {
			isFocused = function()
				return false
			end,
			addListener = function()
				return {
					remove = function() end,
				}
			end,
		}

		local rootElement = React.createElement(NavigationContext.Provider, {
			value = navigationProp,
		}, {
			child = React.createElement(FooWithNavigationFocus),
		})

		local root = ReactRoblox.createRoot(Instance.new("Folder"))
		ReactRoblox.act(function()
			root:render(rootElement)
		end)

		expect(testFocused).toEqual(false)

		ReactRoblox.act(function()
			root:unmount()
		end)
	end)

	it("should re-render and set focused status for events", function()
		local testListeners = {}
		local testFocused = false

		local function Foo(props)
			testFocused = props.isFocused
			return React.createElement("TextButton")
		end

		local FooWithNavigationFocus = withNavigationFocus(Foo)

		local navigationProp = {
			isFocused = function()
				return false
			end,
			addListener = function(event, listener)
				testListeners[event] = listener
				return {
					remove = function()
						testListeners[event] = nil
					end,
				}
			end,
		}

		local rootElement = React.createElement(NavigationContext.Provider, {
			value = navigationProp,
		}, {
			child = React.createElement(FooWithNavigationFocus),
		})

		local root = ReactRoblox.createRoot(Instance.new("Folder"))
		ReactRoblox.act(function()
			root:render(rootElement)
		end)

		expect(testFocused).toEqual(false)
		expect(testListeners[Events.WillFocus]).toEqual(expect.any("function"))
		expect(testListeners[Events.WillBlur]).toEqual(expect.any("function"))

		ReactRoblox.act(function()
			testListeners[Events.WillFocus]()
		end)
		expect(testFocused).toEqual(true)

		ReactRoblox.act(function()
			testListeners[Events.WillBlur]()
		end)
		expect(testFocused).toEqual(false)

		ReactRoblox.act(function()
			root:unmount()
		end)

		expect(testListeners[Events.WillFocus]).toEqual(nil)
		expect(testListeners[Events.WillBlur]).toEqual(nil)
	end)

	it("throws if component is not provided", function()
		expect(function()
			withNavigationFocus(nil)
		end).toThrow("withNavigationFocus must be called with a Roact component (stateful or functional)")
	end)

	it("should throw when used outside of a navigation provider", function()
		local function Foo()
			return nil
		end

		local FooWithNavigationFocus = withNavigationFocus(Foo)

		local errorMessage = "withNavigation and withNavigationFocus can only "
			.. "be used on a view hierarchy of a navigator. The wrapped component is "
			.. "unable to get access to navigation from props or context"

		local root = ReactRoblox.createRoot(Instance.new("Folder"))
		expect(function()
			ReactRoblox.act(function()
				root:render(React.createElement(FooWithNavigationFocus))
			end)
		end).toThrow(errorMessage)
	end)
end
