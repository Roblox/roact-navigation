return function()
	local RoactNavigationModule = script.Parent.Parent
	local NavigationActions = require(RoactNavigationModule.NavigationActions)
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestGlobals).expect

	it("throws when indexing an unknown field", function()
		jestExpect(function()
			return NavigationActions.foo
		end).toThrow('"foo" is not a valid member of NavigationActions')
	end)

	describe("NavigationActions token tests", function()
		it("should return same object for each token for multiple calls", function()
			jestExpect(NavigationActions.Back).toEqual(NavigationActions.Back)
			jestExpect(NavigationActions.Init).toEqual(NavigationActions.Init)
			jestExpect(NavigationActions.Navigate).toEqual(NavigationActions.Navigate)
			jestExpect(NavigationActions.SetParams).toEqual(NavigationActions.SetParams)
		end)

		it("should return matching string names for symbols", function()
			jestExpect(tostring(NavigationActions.Back)).toEqual("BACK")
			jestExpect(tostring(NavigationActions.Init)).toEqual("INIT")
			jestExpect(tostring(NavigationActions.Navigate)).toEqual("NAVIGATE")
			jestExpect(tostring(NavigationActions.SetParams)).toEqual("SET_PARAMS")
		end)
	end)

	describe("NavigationActions function tests", function()
		it("should return a back action with matching data for a call to back()", function()
			local backTable = NavigationActions.back({
				key = "the_key",
				immediate = true,
			})

			jestExpect(backTable.type).toEqual(NavigationActions.Back)
			jestExpect(backTable.key).toEqual("the_key")
			jestExpect(backTable.immediate).toEqual(true)
		end)

		it("should return an init action with matching data for call to init()", function()
			local initTable = NavigationActions.init({
				params = "foo",
			})

			jestExpect(initTable.type).toEqual(NavigationActions.Init)
			jestExpect(initTable.params).toEqual("foo")
		end)

		it("should return a navigate action with matching data for call to navigate()", function()
			local navigateTable = NavigationActions.navigate({
				routeName = "routeName",
				params = "foo",
				action = "action",
				key = "key",
			})

			jestExpect(navigateTable.type).toEqual(NavigationActions.Navigate)
			jestExpect(navigateTable.routeName).toEqual("routeName")
			jestExpect(navigateTable.params).toEqual("foo")
			jestExpect(navigateTable.action).toEqual("action")
			jestExpect(navigateTable.key).toEqual("key")
		end)

		it("should return a set params action with matching data for call to setParams()", function()
			local setParamsTable = NavigationActions.setParams({
				key = "key",
				params = "foo",
			})

			jestExpect(setParamsTable.type).toEqual(NavigationActions.SetParams)
			jestExpect(setParamsTable.key).toEqual("key")
			jestExpect(setParamsTable.params).toEqual("foo")
		end)
	end)
end
