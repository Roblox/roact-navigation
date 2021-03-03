return function()
	local RoactNavigationModule = script.Parent.Parent
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestRoblox).Globals.expect

	local NavigationSymbol = require(RoactNavigationModule.NavigationSymbol)

	it("should give an opaque object", function()
		local symbol = NavigationSymbol("foo")

		jestExpect(typeof(symbol)).toEqual("userdata")
	end)

	it("should coerce to the given name", function()
		local symbol = NavigationSymbol("foo")

		jestExpect(tostring(symbol)).toEqual("foo")
	end)

	it("should be unique when constructed", function()
		local symbolA = NavigationSymbol("abc")
		local symbolB = NavigationSymbol("abc")

		jestExpect(symbolA).never.toBe(symbolB)
	end)
end
