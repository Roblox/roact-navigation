return function()
	local CoreGui = game:GetService("CoreGui")

	local RhodiumTests = script.Parent.Parent
	local Packages = RhodiumTests.Parent.Packages

	local Rhodium = require(Packages.Dev.Rhodium)
	local Element = Rhodium.Element
	local XPath = Rhodium.XPath

	local React = require(Packages.React)
	local RoactNavigation = require(Packages.RoactNavigation)
	local ReactRoblox = require(Packages.Dev.ReactRoblox)

	local JestGlobals = require(Packages.Dev.JestGlobals)
	local expect = JestGlobals.expect

	local createScreenGui = require(RhodiumTests.createScreenGui)

	local function RhodiumTestAbsorbInput(stackPresentationStyle, absorbInputSelectable, expectedSelectable)
		expect(stackPresentationStyle).toBeDefined()

		local screen = createScreenGui(CoreGui)

		local rootNavigator = RoactNavigation.createRobloxStackNavigator({
			{
				MainContent = {
					screen = function()
						return React.createElement("TextButton", {
							Size = UDim2.new(1, 0, 1, 0),
							Text = "Foo",
						})
					end,
					navigationOptions = {
						absorbInputSelectable = absorbInputSelectable,
					},
				},
			},
		})

		local appContainer = RoactNavigation.createAppContainer(rootNavigator)

		local absorbInputPath = XPath.new(screen):cat(XPath.new("View.TransitionerScenes.AbsorbInput"))

		local root = ReactRoblox.createRoot(screen)
		ReactRoblox.act(function()
			root:render(React.createElement(appContainer), {
				detached = true,
			})
		end)

		local absorbInputElement = Element.new(absorbInputPath)
		expect(absorbInputElement:waitForRbxInstance(1)).toEqual(expect.any("Instance"))
		expect(absorbInputElement:getAttribute("Selectable")).toEqual(expectedSelectable)

		ReactRoblox.act(function()
			root:unmount()
		end)
	end

	for _, stackPresentationStyle in pairs(RoactNavigation.StackPresentationStyle) do
		describe(("test AbsorbInput, Mode: %s"):format(tostring(stackPresentationStyle)), function()
			it(
				"the AbsorbInput should not be gamepad/keyboard selectable if absorbInputSelectable is false in navigationOptions",
				function()
					RhodiumTestAbsorbInput(stackPresentationStyle, false, false)
				end
			)
			it(
				"the AbsorbInput should be gamepad/keyboard selectable by defualt if absorbInputSelectable is nil in navigationOptions",
				function()
					RhodiumTestAbsorbInput(stackPresentationStyle, nil, true)
				end
			)
			it(
				"the AbsorbInput should be gamepad/keyboard selectable if absorbInputSelectable is true in navigationOptions",
				function()
					RhodiumTestAbsorbInput(stackPresentationStyle, true, true)
				end
			)
		end)
	end
end
