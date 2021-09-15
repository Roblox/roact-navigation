-- upstream https://github.com/react-navigation/react-navigation/blob/f10543f9fcc0f347c9d23aeb57616fd0f21cd4e3/packages/core/src/__tests__/getChildrenNavigationCache.test.js
return function()
	local RoactNavigationModule = script.Parent.Parent
	local getChildrenNavigationCache = require(RoactNavigationModule.getChildrenNavigationCache)
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestGlobals).expect

	it("should return empty table if navigation arg not provided", function()
		jestExpect(getChildrenNavigationCache()._childrenNavigation).toBeUndefined()
	end)

	it("should populate navigation._childrenNavigation as a side-effect", function()
		local navigation = {
			state = {
				routes = {
					{ key = "one" },
				}
			},
		}
		local result = getChildrenNavigationCache(navigation)
		jestExpect(result).toBeDefined()
		jestExpect(navigation._childrenNavigation).toBe(result)
	end)

	it("should delete children cache keys that are no longer valid", function()
		local navigation = {
			state = {
				routes = {
					{ key = "one" },
					{ key = "two" },
					{ key = "three" },
				}
			},
			_childrenNavigation = {
				one = {},
				two = {},
				three = {},
				four = {},
			}
		}

		local result = getChildrenNavigationCache(navigation)
		jestExpect(result).toEqual({
			one = {},
			two = {},
			three = {},
		})
	end)

	it("should not delete children cache keys if in transitioning state", function()
		local navigation = {
			state = {
				routes = {
					{ key = "one" },
					{ key = "two" },
					{ key = "three" },
				},
				isTransitioning = true,
			},
			_childrenNavigation = {
				one = {},
				two = {},
				three = {},
				four = {},
			}
		}

		local result = getChildrenNavigationCache(navigation)
		jestExpect(result).toEqual({
			one = {},
			two = {},
			three = {},
			four = {},
		})
	end)
end
