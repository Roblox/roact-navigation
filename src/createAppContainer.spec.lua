return function()
	local Roact = require(script.Parent.Parent.Roact)
	local createAppContainer = require(script.Parent.createAppContainer)
	local createSwitchNavigator = require(script.Parent.navigators.createSwitchNavigator)

	it("should be a function", function()
		expect(type(createAppContainer)).to.equal("function")
	end)

	it("should return a valid component when mounting a switch navigator", function()
		local TestNavigator = createSwitchNavigator({
			routes = {
				Foo = function() end,
			},
			initialRouteName = "Foo",
		})

		local TestApp = createAppContainer(TestNavigator)
		local element = Roact.createElement(TestApp)
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	-- TODO: Implement mounting tests for other navigators
end

