return function()
	local CoreGui = game.CoreGui
	local Element = require(game.CoreGui.RobloxGui.Modules.Rhodium.Element)
	local XPath = require(game.CoreGui.RobloxGui.Modules.Rhodium.XPath)

	local Roact = require(script.Parent.Parent.Parent.Roact)
	local RoactNavigation = require(script.Parent.Parent.Parent.RoactNavigation)

	local function createButtonPage(pageName, clickTargetPageName)
		return function(props)
			return Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0.5, 0),
				Size = UDim2.new(0.5, 0, 0.25, 0),
				Text = pageName,
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					props.navigation.navigate(clickTargetPageName)
				end,
			})
		end
	end

	describe("SwitchNavigator Tests", function()
		it("should change pages on navigate operation", function()
			local appContainer = Roact.createElement("ScreenGui", nil, {
				AppContainer = Roact.createElement(RoactNavigation.createAppContainer(
					RoactNavigation.createSwitchNavigator({
						routes = {
							PageOne = createButtonPage("PageOne", "PageTwo"),
							PageTwo = createButtonPage("PageTwo", "PageOne"),
						},
						initialRouteName = "PageOne",
					})
				))
			})

			local rootInstance = Roact.mount(appContainer, CoreGui, "RootContainer")

			local buttonPath = XPath.new("game.CoreGui.RootContainer.AppContainer")
			local buttonElement = Element.new(buttonPath)

			expect(buttonElement:waitForRbxInstance(1)).to.be.ok()
			expect(buttonElement:getText()).to.equal("PageOne")

			buttonElement:click()
			wait()

			local newButtonElement = Element.new(buttonPath)
			expect(newButtonElement:waitForRbxInstance(1)).to.be.ok()
			expect(newButtonElement:getText()).to.equal("PageTwo")

			Roact.unmount(rootInstance)
		end)
	end)
end

