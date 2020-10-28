return function()
	local CoreGui = game:GetService("CoreGui")
	local Element = Rhodium.Element
	local XPath = Rhodium.XPath

	local Packages = script.Parent.Parent.Parent.Packages

	local Roact = require(Packages.Roact)
	local RoactNavigation = require(Packages.RoactNavigation)

	local getUniqueName = require(script.Parent.Parent.getUniqueName)

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
					RoactNavigation.createRobloxSwitchNavigator({
						{ PageOne = createButtonPage("PageOne", "PageTwo") },
						{ PageTwo = createButtonPage("PageTwo", "PageOne") },
					})
				))
			})

			local rootName = getUniqueName()
			local rootInstance = Roact.mount(appContainer, CoreGui, rootName)

			local appPath = XPath.new("game.CoreGui"):cat(XPath.new(rootName))
				:cat(XPath.new("View"))
			local buttonPath = appPath:cat(XPath.new("card_PageOne.Scene"))
			local buttonElement = Element.new(buttonPath)

			expect(buttonElement:waitForRbxInstance(1)).to.be.ok()
			expect(buttonElement:getText()).to.equal("PageOne")

			buttonElement:click()
			wait()

			local button2Path = appPath:cat(XPath.new("card_PageTwo.Scene"))
			local newButtonElement = Element.new(button2Path)
			expect(newButtonElement:waitForRbxInstance(1)).to.be.ok()
			expect(newButtonElement:getText()).to.equal("PageTwo")

			Roact.unmount(rootInstance)
		end)
	end)
end

