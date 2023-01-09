return function()
	local viewsModule = script.Parent.Parent
	local RoactNavigationModule = viewsModule.Parent
	local Packages = RoactNavigationModule.Parent

	local React = require(Packages.React)
	local ReactRoblox = require(Packages.Dev.ReactRoblox)
	local JestGlobals = require(Packages.Dev.JestGlobals)

	local expect = JestGlobals.expect

	local withNavigation = require(viewsModule.withNavigation)
	local NavigationContext = require(viewsModule.NavigationContext)

	it("throws if no component is provided", function()
		expect(function()
			withNavigation(nil)
		end).toThrow("withNavigation must be called with a Roact component (stateful or functional)")
	end)

	it("should extract navigation object from provider and pass it through", function()
		local testNavigation = {}
		local extractedNavigation = nil

		local function Foo(props)
			extractedNavigation = props.navigation
			return nil
		end

		local FooWithNavigation = withNavigation(Foo)

		local rootElement = React.createElement(NavigationContext.Provider, {
			value = testNavigation,
		}, {
			Child = React.createElement(FooWithNavigation),
		})

		local root = ReactRoblox.createRoot(Instance.new("Folder"))
		ReactRoblox.act(function()
			root:render(rootElement)
		end)

		ReactRoblox.act(function()
			root:unmount()
		end)

		expect(extractedNavigation).toBe(testNavigation)
	end)

	it("should update with new navigation when navigation is updated", function()
		local testNavigation = {}
		local testNavigation2 = {}
		local extractedNavigation = nil

		local function Foo(props)
			extractedNavigation = props.navigation
			return nil
		end

		local FooWithNavigation = withNavigation(Foo)

		local rootElement = React.createElement(NavigationContext.Provider, {
			value = testNavigation,
		}, {
			Child = React.createElement(FooWithNavigation),
		})

		local root = ReactRoblox.createRoot(Instance.new("Folder"))
		ReactRoblox.act(function()
			root:render(rootElement)
		end)

		local rootElement2 = React.createElement(NavigationContext.Provider, {
			value = testNavigation2,
		}, {
			Child = React.createElement(FooWithNavigation),
		})

		ReactRoblox.act(function()
			root:render(rootElement2)
		end)

		ReactRoblox.act(function()
			root:unmount()
		end)

		expect(extractedNavigation).toBe(testNavigation2)
	end)

	it("should throw when used outside of a navigation provider", function()
		local function Foo(_props)
			return nil
		end

		local FooWithNavigation = withNavigation(Foo)

		local element = React.createElement(FooWithNavigation)

		local errorMessage = "withNavigation and withNavigationFocus can only "
			.. "be used on a view hierarchy of a navigator. The wrapped component is "
			.. "unable to get access to navigation from props or context"

		local root = ReactRoblox.createRoot(Instance.new("Folder"))
		expect(function()
			ReactRoblox.act(function()
				root:render(element)
			end)
		end).toThrow(errorMessage)
	end)
end
