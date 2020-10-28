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

	describe("StackNavigator Tests", function()
		it("should animate page change on navigate operation", function()
			local appContainer = Roact.createElement("ScreenGui", nil, {
				AppContainer = Roact.createElement(RoactNavigation.createAppContainer(
					RoactNavigation.createRobloxStackNavigator({
						{ PageOne = createButtonPage("PageOne", "PageTwo") },
						{ PageTwo = createButtonPage("PageTwo", "PageOne") },
					})
				))
			})

			local rootName = getUniqueName()
			local rootPath = XPath.new("game.CoreGui"):cat(XPath.new(rootName))
				:cat(XPath.new("View.TransitionerScenes"))
			local scene1Path = rootPath:cat(XPath.new("1.DynamicContent.*.Scene"))
			local scene2Path = rootPath:cat(XPath.new("2.DynamicContent.*.Scene"))

			local rootInstance = Roact.mount(appContainer, CoreGui, rootName)

			local button1Element = Element.new(scene1Path)
			expect(button1Element:waitForRbxInstance(1)).to.be.ok()
			expect(button1Element:getText()).to.equal("PageOne")

			button1Element:click()

			local scene2ButtonElement = Element.new(scene2Path)
			expect(scene2ButtonElement:waitForRbxInstance(1)).to.be.ok()
			expect(scene2ButtonElement:getText()).to.equal("PageTwo")

			Roact.unmount(rootInstance)
		end)
	end)
end

