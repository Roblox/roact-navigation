return function()
	local routersModule = script.Parent.Parent
	local RoactNavigationModule = routersModule.Parent
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestRoblox).Globals.expect

	local SwitchActions = require(routersModule.SwitchActions)

	it("throws when indexing an unknown field", function()
		jestExpect(function()
			return SwitchActions.foo
		end).toThrow("\"foo\" is not a valid member of SwitchActions")
	end)

	describe("token tests", function()
		it("returns same object for each token for multiple calls", function()
			jestExpect(SwitchActions.JumpTo).toBe(SwitchActions.JumpTo)
		end)

		it("should return matching string names for symbols", function()
			jestExpect(tostring(SwitchActions.JumpTo)).toEqual("JUMP_TO")
		end)
	end)

	describe("creators", function()
		it("returns a JumpTo action for jumpTo()", function()
			local popTable = SwitchActions.jumpTo({
				routeName = "foo",
			})

			jestExpect(popTable.type).toBe(SwitchActions.JumpTo)
			jestExpect(popTable.routeName).toEqual("foo")
			jestExpect(popTable.preserveFocus).toEqual(true)
		end)
	end)
end
