return function()
	local Packages = script.Parent.Parent.Parent.Parent
	local React = require(Packages.React)
	local ReactRoblox = require(Packages.Dev.ReactRoblox)
	local JestGlobals = require(Packages.Dev.JestGlobals)
	local RobloxSwitchView = require(script.Parent.Parent.RobloxSwitchView)

	local expect = JestGlobals.expect

	local function makeDescriptors(navProp, fooComponent, componentBar)
		return {
			Foo = {
				getComponent = function()
					return fooComponent
				end,
				navigation = navProp,
			},
			Bar = {
				getComponent = function()
					return componentBar
				end,
				navigation = navProp,
			},
		}
	end

	it("should mount and pass required props and context", function()
		local testScreenProps = {}
		local testNavigation = {
			state = {
				routes = {
					{ routeName = "Foo", key = "Foo" },
				},
				index = 1,
			},
		}

		local testComponentNavigationFromProp = nil
		local testComponentScreenProps = nil

		local TestComponent = React.Component:extend("TestComponent")
		function TestComponent:render()
			testComponentNavigationFromProp = self.props.navigation
			testComponentScreenProps = self.props.screenProps
			return nil
		end

		local testDescriptors = {
			Foo = {
				getComponent = function()
					return TestComponent
				end,
				navigation = testNavigation,
			},
		}

		local element = React.createElement(RobloxSwitchView, {
			screenProps = testScreenProps,
			navigation = testNavigation,
			descriptors = testDescriptors,
		})

		local root = ReactRoblox.createRoot(Instance.new("Folder"))
		ReactRoblox.act(function()
			root:render(element)
		end)

		ReactRoblox.act(function()
			root:unmount()
		end)

		expect(testComponentNavigationFromProp).toBe(testNavigation)
		expect(testComponentScreenProps).toBe(testScreenProps)
	end)

	it("should unmount inactive pages when keepVisitedScreensMounted is false", function()
		local fooUnmounted = false
		local TestComponentFoo = React.Component:extend("TestComponentFoo")
		function TestComponentFoo:render() end
		function TestComponentFoo:willUnmount()
			fooUnmounted = true
		end

		local TestComponentBar = React.Component:extend("TestComponentBar")
		function TestComponentBar:render() end

		local testNavigation1 = {
			state = {
				routes = {
					{ routeName = "Foo", key = "Foo" },
					{ routeName = "Bar", key = "Bar" },
				},
				index = 1,
			},
		}

		local element = React.createElement(RobloxSwitchView, {
			screenProps = {},
			navigation = testNavigation1,
			descriptors = makeDescriptors(testNavigation1, TestComponentFoo, TestComponentBar),
			navigationConfig = {
				keepVisitedScreensMounted = false,
			},
		})

		local root = ReactRoblox.createRoot(Instance.new("Folder"))
		ReactRoblox.act(function()
			root:render(element)
		end)

		expect(fooUnmounted).toEqual(false)

		local testNavigation2 = {
			state = {
				routes = {
					{ routeName = "Foo", key = "Foo" },
					{ routeName = "Bar", key = "Bar" },
				},
				index = 2,
			},
		}

		ReactRoblox.act(function()
			root:render(React.createElement(RobloxSwitchView, {
				screenProps = {},
				navigation = testNavigation2,
				descriptors = makeDescriptors(testNavigation2, TestComponentFoo, TestComponentBar),
				navigationConfig = {
					keepVisitedScreensMounted = false,
				},
			}))
		end)

		expect(fooUnmounted).toEqual(true)
		ReactRoblox.act(function()
			root:unmount()
		end)
	end)

	it("should not unmount inactive pages when keepVisitedScreensMounted is true", function()
		local fooUnmounted = false
		local TestComponentFoo = React.Component:extend("TestComponentFoo")
		function TestComponentFoo:render() end
		function TestComponentFoo:willUnmount()
			fooUnmounted = true
		end

		local TestComponentBar = React.Component:extend("TestComponentBar")
		function TestComponentBar:render() end

		local testNavigation1 = {
			state = {
				routes = {
					{ routeName = "Foo", key = "Foo" },
					{ routeName = "Bar", key = "Bar" },
				},
				index = 1,
			},
		}

		local element = React.createElement(RobloxSwitchView, {
			screenProps = {},
			navigation = testNavigation1,
			descriptors = makeDescriptors(testNavigation1, TestComponentFoo, TestComponentBar),
			navigationConfig = {
				keepVisitedScreensMounted = true,
			},
		})

		local root = ReactRoblox.createRoot(Instance.new("Folder"))
		ReactRoblox.act(function()
			root:render(element)
		end)
		expect(fooUnmounted).toEqual(false)

		local testNavigation2 = {
			state = {
				routes = {
					{ routeName = "Foo", key = "Foo" },
					{ routeName = "Bar", key = "Bar" },
				},
				index = 2,
			},
		}

		root:render(React.createElement(RobloxSwitchView, {
			screenProps = {},
			navigation = testNavigation2,
			descriptors = makeDescriptors(testNavigation2, TestComponentFoo, TestComponentBar),
			navigationConfig = {
				keepVisitedScreensMounted = true,
			},
		}))

		expect(fooUnmounted).toEqual(false)

		ReactRoblox.act(function()
			root:unmount()
		end)
		expect(fooUnmounted).toEqual(true)
	end)

	it("should unmount inactive pages when keepVisitedScreensMounted switches from true to false", function()
		local fooUnmounted = false
		local TestComponentFoo = React.Component:extend("TestComponentFoo")
		function TestComponentFoo:render() end
		function TestComponentFoo:willUnmount()
			fooUnmounted = true
		end

		local TestComponentBar = React.Component:extend("TestComponentBar")
		function TestComponentBar:render() end

		local testNavigation1 = {
			state = {
				routes = {
					{ routeName = "Foo", key = "Foo" },
					{ routeName = "Bar", key = "Bar" },
				},
				index = 1,
			},
		}

		local element = React.createElement(RobloxSwitchView, {
			screenProps = {},
			navigation = testNavigation1,
			descriptors = makeDescriptors(testNavigation1, TestComponentFoo, TestComponentBar),
			navigationConfig = {
				keepVisitedScreensMounted = true,
			},
		})

		local root = ReactRoblox.createRoot(Instance.new("Folder"))
		ReactRoblox.act(function()
			root:render(element)
		end)

		local testNavigation2 = {
			state = {
				routes = {
					{ routeName = "Foo", key = "Foo" },
					{ routeName = "Bar", key = "Bar" },
				},
				index = 2,
			},
		}

		-- We must update tree to make sure active screens list gets updated first!
		ReactRoblox.act(function()
			root:render(React.createElement(RobloxSwitchView, {
				screenProps = {},
				navigation = testNavigation2,
				descriptors = makeDescriptors(testNavigation2, TestComponentFoo, TestComponentBar),
				navigationConfig = {
					keepVisitedScreensMounted = true,
				},
			}))
		end)

		expect(fooUnmounted).toEqual(false)

		ReactRoblox.act(function()
			root:render(React.createElement(RobloxSwitchView, {
				screenProps = {},
				navigation = testNavigation2,
				descriptors = makeDescriptors(testNavigation2, TestComponentFoo, TestComponentBar),
				navigationConfig = {
					keepVisitedScreensMounted = false,
				},
			}))
		end)

		expect(fooUnmounted).toEqual(true)

		ReactRoblox.act(function()
			root:unmount()
		end)
	end)
end
