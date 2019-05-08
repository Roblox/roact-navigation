return function()
	local getChildNavigation = require(script.Parent.getChildNavigation)

	it("should be a function", function()
		expect(type(getChildNavigation)).to.equal("function")
	end)

	itSKIP("should have its tests implemented soon", function()
		error("not implemented")
	end)
end
