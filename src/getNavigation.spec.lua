return function()
	local getNavigation = require(script.Parent.getNavigation)

	it("should be a function", function()
		expect(type(getNavigation)).to.equal("function")
	end)

	itSKIP("should have the rest of its tests implemented soon", function()
		error("not implemented")
	end)
end
