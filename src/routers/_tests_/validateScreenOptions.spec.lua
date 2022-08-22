return function()
	local routersModule = script.Parent.Parent
	local RoactNavigationModule = routersModule.Parent
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestGlobals).expect

	local validateScreenOptions = require(routersModule.validateScreenOptions)

	it("should not throw when there are no problems", function()
		jestExpect(function()
			validateScreenOptions({ title = "foo" }, { routeName = "foo" })
		end).never.toThrow()
	end)

	it("should throw error if no routeName is provided", function()
		jestExpect(function()
			validateScreenOptions({ title = "bar" }, {})
		end).toThrow("route.routeName must be a string")
	end)

	it("should throw error for options with function for title", function()
		jestExpect(function()
			validateScreenOptions({
				title = function() end,
			}, { routeName = "foo" })
		end).toThrow()
	end)
end
