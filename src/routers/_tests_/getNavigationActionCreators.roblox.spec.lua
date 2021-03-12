return function()
	local routersModule = script.Parent.Parent
	local RoactNavigationModule = routersModule.Parent
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestRoblox).Globals.expect

	local getNavigationActionCreators = require(routersModule.getNavigationActionCreators)
	local NavigationActions = require(RoactNavigationModule.NavigationActions)

	it("should return a table with correct functions when called", function()
		local result = getNavigationActionCreators()
		jestExpect(result.goBack).toEqual(jestExpect.any("function"))
		jestExpect(result.navigate).toEqual(jestExpect.any("function"))
		jestExpect(result.setParams).toEqual(jestExpect.any("function"))
	end)

	describe("goBack tests", function()
		it("should return a Back action when called", function()
			local result = getNavigationActionCreators().goBack("theKey")
			jestExpect(result.type).toBe(NavigationActions.Back)
			jestExpect(result.key).toEqual("theKey")
		end)

		it("should throw when route.key is not a string", function()
			jestExpect(function()
				getNavigationActionCreators({ key = 5 }).goBack()
			end).toThrow(".goBack(): key should be a string")
		end)

		it("should fall back to route.key if key is not provided", function()
			local result = getNavigationActionCreators({ key = "routeKey" }).goBack()
			jestExpect(result.key).toEqual("routeKey")
		end)

		it("should override route.key if key is provided", function()
			local result = getNavigationActionCreators({ key = "routeKey" }).goBack("theKey")
			jestExpect(result.key).toEqual("theKey")
		end)
	end)

	describe("navigate tests", function()
		it("should return a Navigate action when called", function()
			local theParams = {}
			local childAction = {}
			local result = getNavigationActionCreators().navigate("theRoute", theParams, childAction)
			jestExpect(result.type).toBe(NavigationActions.Navigate)
			jestExpect(result.routeName).toEqual("theRoute")
			jestExpect(result.params).toBe(theParams)
			jestExpect(result.action).toBe(childAction)
		end)

		it("should return a navigate action with matching properties when called with a table", function()
			local testNavigateTo = {
				routeName = "theRoute",
				params = {},
				action = {},
			}

			local result = getNavigationActionCreators().navigate(testNavigateTo)
			jestExpect(result.type).toBe(NavigationActions.Navigate)
			jestExpect(result.routeName).toEqual("theRoute")
			jestExpect(result.params).toBe(testNavigateTo.params)
			jestExpect(result.action).toBe(testNavigateTo.action)
		end)

		it("should throw when navigateTo is not a valid type", function()
			jestExpect(function()
				getNavigationActionCreators().navigate(5)
			end).toThrow(".navigate(): navigateTo must be a string or table")
		end)

		it("should throw when params is provided with a table navigateTo", function()
			jestExpect(function()
				getNavigationActionCreators().navigate({}, {})
			end).toThrow(".navigate(): params can only be provided with a string navigateTo value")
		end)

		it("should throw when action is provided with a table navigateTo", function()
			jestExpect(function()
				getNavigationActionCreators().navigate({}, nil, {})
			end).toThrow(".navigate(): child action can only be provided with a string navigateTo value")
		end)
	end)

	describe("setParams tests", function()
		it("should return a SetParams action when called", function()
			local theParams = {}
			local result = getNavigationActionCreators({ key = "theKey" }).setParams(theParams)
			jestExpect(result.type).toBe(NavigationActions.SetParams)
			jestExpect(result.key).toEqual("theKey")
			jestExpect(result.params).toBe(theParams)
		end)

		it("should throw when called by a root navigator", function()
			jestExpect(function()
				getNavigationActionCreators({}).setParams({})
			end).toThrow(".setParams(): cannot be called by the root navigator")
		end)
	end)
end
