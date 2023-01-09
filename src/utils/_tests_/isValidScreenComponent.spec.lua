return function()
	local utilsModule = script.Parent.Parent
	local Packages = utilsModule.Parent.Parent

	local React = require(Packages.React)
	local isValidScreenComponent = require(utilsModule.isValidScreenComponent)

	local TestComponent = React.Component:extend("TestFoo")

	function TestComponent:render() end

	it("should return true for valid element types", function()
		-- Function Component is valid
		expect(isValidScreenComponent(function() end)).to.equal(true)
		-- Stateful Component is valid
		expect(isValidScreenComponent(TestComponent)).to.equal(true)
		expect(isValidScreenComponent({
			render = function()
				return TestComponent
			end,
		})).to.equal(true)
		expect(isValidScreenComponent( -- we do not test if render function returns valid component
			{ render = function() end }
		)).to.equal(true)
	end)

	it("should return false for invalid element types", function()
		expect(isValidScreenComponent("foo")).to.equal(false)
		expect(isValidScreenComponent(React.createElement("Frame"))).to.equal(false)
		expect(isValidScreenComponent(5)).to.equal(false)
		expect(isValidScreenComponent({ render = "bad" })).to.equal(false)
		expect(isValidScreenComponent({
			notRender = function()
				return "foo"
			end,
		})).to.equal(false)
	end)
end
