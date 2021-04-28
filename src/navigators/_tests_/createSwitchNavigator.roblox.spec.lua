return function()
	local navigatorsModule = script.Parent.Parent
	local RoactNavigationModule = navigatorsModule.Parent
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestRoblox).Globals.expect
	local Roact = require(Packages.Roact)

	local createSwitchNavigator = require(navigatorsModule.createSwitchNavigator)
	local getChildNavigation = require(RoactNavigationModule.getChildNavigation)

	it("should return a mountable Roact component", function()
		local navigator = createSwitchNavigator({
			{ Foo = function() end },
		})

		local testNavigation = {
			state = {
				routes = {
					{ routeName = "Foo", key = "Foo" },
				},
				index = 1
			},
			router = navigator.router
		}

		function testNavigation.getChildNavigation(childKey)
			return getChildNavigation(testNavigation, childKey, function()
				return testNavigation
			end)
		end

		function testNavigation.addListener(_symbol, _callback)
			return {
				remove = function() end
			}
		end

		jestExpect(function()
			local instance = Roact.mount(Roact.createElement(navigator, {
				navigation = testNavigation
			}))

			Roact.unmount(instance)
		end).never.toThrow()
	end)
end

