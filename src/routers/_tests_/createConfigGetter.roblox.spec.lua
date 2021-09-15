return function()
	local routersModule = script.Parent.Parent
	local RoactNavigationModule = routersModule.Parent
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestGlobals).expect

	local createConfigGetter = require(routersModule.createConfigGetter)

	it("should return a function", function()
		local result = createConfigGetter({}, {})
		jestExpect(result).toEqual(jestExpect.any("function"))
	end)

	it("should override default config with component-specific config", function()
		local getScreenOptions = createConfigGetter({
			Home = {
				screen = {
					render = function() end,
					navigationOptions = { title = "ComponentHome" },
				},
			},
			defaultNavigationOptions = { title = "DefaultTitle" },
		})

		jestExpect(getScreenOptions({ state = { routeName = "Home" } }).title).toEqual("ComponentHome")
	end)

	it("should override component-specific config with route-specific config", function()
		local getScreenOptions = createConfigGetter({
			Home = {
				screen = {
					render = function() end,
					navigationOptions = { title = "ComponentHome" },
				},
				navigationOptions = { title = "RouteHome" },
			},
			defaultNavigationOptions = { title = "DefaultTitle" },
		})

		jestExpect(getScreenOptions({ state = { routeName = "Home" } }).title).toEqual("RouteHome")
	end)
end
