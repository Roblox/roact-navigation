return function()
	local CoreGui = game.CoreGui
	local Element = require(game.CoreGui.RobloxGui.Modules.Rhodium.Element)
	local XPath = require(game.CoreGui.RobloxGui.Modules.Rhodium.XPath)

	local Roact = require(script.Parent.Parent.Parent.Roact)
	local RoactNavigation = require(script.Parent.Parent.Parent.RoactNavigation)

	local function createButtonPage(pageName, clickTargetPageName)
		return function(props)
			return Roact.createElement("TextButton", {
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Size = UDim2.new(1, 0, 1, 0),
				Text = pageName,
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[Roact.Event.Activated] = function()
					props.navigation.navigate(clickTargetPageName)
				end,
			})
		end
	end

	describe("TopBarStackNavigator Tests", function()
		it("should animate page change on navigate operation", function()
			local appContainer = Roact.createElement("ScreenGui", nil, {
				AppContainer = Roact.createElement(RoactNavigation.createAppContainer(
					RoactNavigation.createTopBarStackNavigator({
						routes = {
							PageOne = createButtonPage("PageOne", "PageTwo"),
							PageTwo = createButtonPage("PageTwo", "PageOne"),
						},
						initialRouteName = "PageOne",
					})
				))
			})

			local rootPath = XPath.new("game.CoreGui.RootContainer.AppContainer.$InnerComponent.scenesContainer")
			local scene1Path = rootPath:cat(XPath.new("1.card.$content.sceneWrapper.scene"))
			local scene2Path = rootPath:cat(XPath.new("2.card.$content.sceneWrapper.scene"))

			local rootInstance = Roact.mount(appContainer, CoreGui, "RootContainer")

			local buttonElement = Element.new(scene1Path)
			expect(buttonElement:waitForRbxInstance(1)).to.be.ok()
			expect(buttonElement:getText()).to.equal("PageOne")

			buttonElement:click()

			local newButtonElement = Element.new(scene2Path)
			expect(newButtonElement:waitForRbxInstance(1)).to.be.ok()
			expect(newButtonElement:getText()).to.equal("PageTwo")

			Roact.unmount(rootInstance)
		end)
	end)
end

