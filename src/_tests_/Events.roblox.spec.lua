return function()
	local RoactNavigationModule = script.Parent.Parent
	local Events = require(RoactNavigationModule.Events)
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestRoblox).Globals.expect

	describe("Events token tests", function()
		it("should return same object for each token for multiple calls", function()
			jestExpect(Events.WillFocus).toBe(Events.WillFocus)
			jestExpect(Events.DidFocus).toBe(Events.DidFocus)
			jestExpect(Events.WillBlur).toBe(Events.WillBlur)
			jestExpect(Events.DidBlur).toBe(Events.DidBlur)
			jestExpect(Events.Action).toBe(Events.Action)
			jestExpect(Events.Refocus).toBe(Events.Refocus)
		end)

		it("should return matching string names for symbols", function()
			jestExpect(tostring(Events.WillFocus)).toEqual("WILL_FOCUS")
			jestExpect(tostring(Events.DidFocus)).toEqual("DID_FOCUS")
			jestExpect(tostring(Events.WillBlur)).toEqual("WILL_BLUR")
			jestExpect(tostring(Events.DidBlur)).toEqual("DID_BLUR")
			jestExpect(tostring(Events.Action)).toEqual("ACTION")
			jestExpect(tostring(Events.Refocus)).toEqual("REFOCUS")
		end)
	end)
end
