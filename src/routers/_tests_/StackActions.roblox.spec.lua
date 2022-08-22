return function()
	local routersModule = script.Parent.Parent
	local RoactNavigationModule = routersModule.Parent
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestGlobals).expect

	local StackActions = require(routersModule.StackActions)

	it("throws when indexing an unknown field", function()
		jestExpect(function()
			return StackActions.foo
		end).toThrow('"foo" is not a valid member of StackActions')
	end)

	describe("StackActions token tests", function()
		it("should return same object for each token for multiple calls", function()
			jestExpect(StackActions.Pop).toBe(StackActions.Pop)
			jestExpect(StackActions.PopToTop).toBe(StackActions.PopToTop)
			jestExpect(StackActions.Push).toBe(StackActions.Push)
			jestExpect(StackActions.Reset).toBe(StackActions.Reset)
			jestExpect(StackActions.Replace).toBe(StackActions.Replace)
		end)

		it("should return matching string names for symbols", function()
			jestExpect(tostring(StackActions.Pop)).toEqual("POP")
			jestExpect(tostring(StackActions.PopToTop)).toEqual("POP_TO_TOP")
			jestExpect(tostring(StackActions.Push)).toEqual("PUSH")
			jestExpect(tostring(StackActions.Reset)).toEqual("RESET")
			jestExpect(tostring(StackActions.Replace)).toEqual("REPLACE")
		end)
	end)

	describe("StackActions function tests", function()
		it("should return a pop action for pop()", function()
			local popTable = StackActions.pop({
				n = "n",
			})

			jestExpect(popTable.type).toBe(StackActions.Pop)
			jestExpect(popTable.n).toEqual("n")
		end)

		it("should return a pop to top action for popToTop()", function()
			local popToTopTable = StackActions.popToTop()

			jestExpect(popToTopTable.type).toBe(StackActions.PopToTop)
		end)

		it("should return a push action for push()", function()
			local pushTable = StackActions.push({
				routeName = "routeName",
				params = "params",
				action = "action",
			})

			jestExpect(pushTable.type).toBe(StackActions.Push)
			jestExpect(pushTable.routeName).toEqual("routeName")
			jestExpect(pushTable.params).toEqual("params")
			jestExpect(pushTable.action).toEqual("action")
		end)

		it("should return a reset action for reset()", function()
			local resetTable = StackActions.reset({
				index = "index",
				actions = "actions",
				key = "key",
			})

			jestExpect(resetTable.type).toBe(StackActions.Reset)
			jestExpect(resetTable.index).toEqual("index")
			jestExpect(resetTable.key).toEqual("key")
		end)

		it("should return a replace action for replace()", function()
			local replaceTable = StackActions.replace({
				key = "key",
				newKey = "newKey",
				routeName = "routeName",
				params = "params",
				action = "action",
				immediate = "immediate",
			})

			jestExpect(replaceTable.type).toBe(StackActions.Replace)
			jestExpect(replaceTable.key).toEqual("key")
			jestExpect(replaceTable.newKey).toEqual("newKey")
			jestExpect(replaceTable.routeName).toEqual("routeName")
			jestExpect(replaceTable.params).toEqual("params")
			jestExpect(replaceTable.action).toEqual("action")
			jestExpect(replaceTable.immediate).toEqual("immediate")
		end)

		it("should return a complete transition action with matching data for call to completeTransition()", function()
			local completeTransitionTable = StackActions.completeTransition({
				key = "key",
				toChildKey = "toChildKey",
			})

			jestExpect(completeTransitionTable.type).toBe(StackActions.CompleteTransition)
			jestExpect(completeTransitionTable.key).toEqual("key")
			jestExpect(completeTransitionTable.toChildKey).toEqual("toChildKey")
		end)
	end)
end
