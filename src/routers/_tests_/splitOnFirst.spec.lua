-- upstream: https://github.com/sindresorhus/split-on-first/blob/v1.1.0/test.js
return function()
	local routersModule = script.Parent.Parent
	local RoactNavigationModule = routersModule.Parent
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestRoblox).Globals.expect

	local splitOnFirst = require(routersModule.splitOnFirst)

	it("main", function()
		jestExpect(splitOnFirst("a-b-c", "-")).toEqual({"a", "b-c"})
		jestExpect(splitOnFirst("key:value:value2", ":")).toEqual({"key", "value:value2"})
		jestExpect(splitOnFirst("a---b---c", "---")).toEqual({"a", "b---c"})
		jestExpect(splitOnFirst("a-b-c", "+")).toEqual({"a-b-c"})
		jestExpect(splitOnFirst("abc", "")).toEqual({"abc"})
	end)
end
