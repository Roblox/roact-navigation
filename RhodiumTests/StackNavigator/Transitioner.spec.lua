return function()
	local CoreGui = game:GetService("CoreGui")
	local RunService = game:GetService("RunService")

	local RhodiumTests = script.Parent.Parent
	local Packages = RhodiumTests.Parent.Packages

	local createScreenGui = require(RhodiumTests.createScreenGui)

	local Roact = require(Packages.Roact)

	local Transitioner = require(Packages.RoactNavigation.views.RobloxStackView.Transitioner)

	it("should not invoke setState after unmounting", function()
		local noop = function() end

		local transitionerComponent
		local element = Roact.createElement(Transitioner, {
			render = function(_, _, selfForTesting)
				transitionerComponent = selfForTesting
			end,
			configureTransition = noop,
			onTransitionStart = noop,
			onTransitionEnd = noop,
			onTransitionStep = noop,
			navigation = {
				state = {
					index = 1,
					routes = {
						{
							routeName = "Route1",
							key = "Route1",
						},
					},
				},
			},
			screenProps = {},
			descriptors = {},
		})

		local screen = createScreenGui(CoreGui)

		local parentFrame = Instance.new("Frame")
		parentFrame.Parent = screen

		parentFrame.Size = UDim2.fromOffset(100, 100)
		local roactTree = Roact.mount(element, parentFrame)
		expect(#parentFrame:GetChildren()).to.equal(1)
		local transitionerInstance = parentFrame:GetChildren()[1]

		parentFrame.Size = UDim2.fromOffset(200, 200)
		RunService.Heartbeat:Wait()
		Roact.unmount(roactTree)

		expect(transitionerComponent).to.be.ok()
		expect(transitionerComponent._doOnAbsoluteSizeChanged).to.be.ok()
		-- The call below should NOT invoke setState because the component has been unmounted.
		transitionerComponent._doOnAbsoluteSizeChanged(transitionerInstance)
	end)
end
