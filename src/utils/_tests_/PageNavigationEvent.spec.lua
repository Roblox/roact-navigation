return function()
	local utils = script.Parent.Parent
	local root = utils.Parent
	local Packages = root.Parent

	local RoactNavigation = require(root)
	local JestGlobals = require(Packages.Dev.JestGlobals)

	local expect = JestGlobals.expect

	local PageNavigationEvent = require(utils.PageNavigationEvent)

	local testPage = "TEST PAGE"
	local willFocusEvent = RoactNavigation.Events.WillFocus

	it("should validate constructor inputs", function()
		expect(function()
			PageNavigationEvent.new(testPage, willFocusEvent)
		end).never.toThrow()

		expect(function()
			PageNavigationEvent.new(testPage, 1)
		end).toThrow()
		expect(function()
			PageNavigationEvent.new(testPage, "event")
		end).toThrow()
		expect(function()
			PageNavigationEvent.new(testPage, nil)
		end).toThrow()
		expect(function()
			PageNavigationEvent.new(testPage, {some = "junk"})
		end).toThrow()
		expect(function()
			PageNavigationEvent.new(1, willFocusEvent)
		end).toThrow()
		expect(function()
			PageNavigationEvent.new(nil, willFocusEvent)
		end).toThrow()
		expect(function()
			PageNavigationEvent.new({"bogus"}, willFocusEvent)
		end).toThrow()
	end)

	it("should be constructed from page name and RoactNavigation.Events", function()
		for _, event in pairs(RoactNavigation.Events) do
			local pageName = testPage .. tostring(event)
			local testPageNavigationEvent = PageNavigationEvent.new(pageName, event)
			expect(testPageNavigationEvent.pageName).toEqual(pageName)
			expect(testPageNavigationEvent.event).toEqual(event)
			expect(PageNavigationEvent.isPageNavigationEvent(testPageNavigationEvent)).toEqual(true)
		end
	end)

	it("should implement tostring and eq", function()
		for _, event in pairs(RoactNavigation.Events) do
			local pageName = testPage .. tostring(event)
			local testPageNavigationEvent = PageNavigationEvent.new(pageName, event)
			expect(testPageNavigationEvent:equalTo(PageNavigationEvent.new(pageName, event))).toEqual(true)
			expect(tostring(testPageNavigationEvent)).toEqual(string.format("%-15s - %s",tostring(event), pageName))
		end

		local testPageNavigationEvent = PageNavigationEvent.new(testPage, willFocusEvent)
		local willFocus = PageNavigationEvent.new(testPage, willFocusEvent)
		expect(testPageNavigationEvent:equalTo(willFocus)).toEqual(true)
		local bogusWillFocus = PageNavigationEvent.new(testPage .. "bogus", willFocusEvent)
		expect(testPageNavigationEvent:equalTo(bogusWillFocus)).toEqual(false)
		local willBlur = PageNavigationEvent.new(testPage, RoactNavigation.Events.WillBlur)
		expect(testPageNavigationEvent:equalTo(willBlur)).toEqual(false)
	end)
end
