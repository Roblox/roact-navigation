return function()
	local RoactNavigationModule = script.Parent.Parent
	local getChildRouter = require(RoactNavigationModule.getChildRouter)
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestRoblox).Globals.expect

	it("should throw if router is not a table", function()
		jestExpect(function()
			getChildRouter(5, "myRoute")
		end).toThrow("router must be a table")
	end)

	it("should throw if routeName is not a string", function()
		jestExpect(function()
			getChildRouter({}, 5)
		end).toThrow("routeName must be a string")
	end)

	it("should return child router if found", function()
		local childRouter = {}
		local result = getChildRouter({
			childRouters = {
				myRoute = childRouter,
			}
		}, "myRoute")

		jestExpect(result).toBe(childRouter)
	end)

	it("should look up component router if no child router is found", function()
		local component = { router = {} }

		local result = getChildRouter({
			getComponentForRouteName = function(routeName)
				if routeName == "myRoute" then
					return component
				else
					return nil
				end
			end
		}, "myRoute")

		jestExpect(result).toBe(component.router)
	end)

	it("should throw if no child routers are specified and getComponentForRouteName is not a function", function()
		jestExpect(function()
			getChildRouter({
				getComponentForRouteName = 5
			}, "myRoute")
		end).toThrow("router.getComponentForRouteName must be a function if no child routers are specified")
	end)
end
