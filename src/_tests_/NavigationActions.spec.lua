-- upstream https://github.com/react-navigation/react-navigation/blob/72e8160537954af40f1b070aa91ef45fc02bba69/packages/core/src/__tests__/NavigationActions.test.js

return function()
	local RoactNavigationModule = script.Parent.Parent
	local NavigationActions = require(RoactNavigationModule.NavigationActions)
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestGlobals).expect

	describe("generic navigation actions", function()
		local params = { foo = "bar" }
		local navigateAction = NavigationActions.navigate({ routeName = "another" })

		it("exports back action and type", function()
			jestExpect(NavigationActions.back()).toEqual({ type = NavigationActions.Back })
			jestExpect(NavigationActions.back({ key = "test" })).toEqual({
				type = NavigationActions.Back,
				key = "test",
			})
		end)

		it("exports init action and type", function()
			jestExpect(NavigationActions.init()).toEqual({ type = NavigationActions.Init })
			jestExpect(NavigationActions.init({ params = params })).toEqual({
				type = NavigationActions.Init,
				params = params,
			})
		end)

		it("exports navigate action and type", function()
			jestExpect(NavigationActions.navigate({ routeName = "test" })).toEqual({
				type = NavigationActions.Navigate,
				routeName = "test",
			})
			jestExpect(NavigationActions.navigate({
				routeName = "test",
				params = params,
				action = navigateAction,
			})).toEqual({
				type = NavigationActions.Navigate,
				routeName = "test",
				params = params,
				action = {
					type = NavigationActions.Navigate,
					routeName = "another",
				},
			})
		end)

		it("exports setParams action and type", function()
			jestExpect(NavigationActions.setParams({
				key = "test",
				params = params,
			})).toEqual({
				type = NavigationActions.SetParams,
				key = "test",
				preserveFocus = true,
				params = params,
			})
		end)
	end)
end
