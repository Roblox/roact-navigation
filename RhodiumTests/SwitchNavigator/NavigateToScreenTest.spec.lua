return function()
	local CoreGui = game:GetService("CoreGui")

	local RhodiumTests = script.Parent.Parent
	local Packages = RhodiumTests.Parent.Packages

	local Rhodium = require(Packages.Dev.Rhodium)
	local Element = Rhodium.Element
	local XPath = Rhodium.XPath

	local React = require(Packages.React)
	local ReactRoblox = require(Packages.Dev.ReactRoblox)
	local RoactNavigation = require(Packages.RoactNavigation)

	local createScreenGui = require(RhodiumTests.createScreenGui)

	local function createButtonPage(pageName, clickTargetPageName)
		return function(props)
			return React.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0.5, 0, 0),
				Size = UDim2.new(0.5, 0, 0.25, 0),
				Text = pageName,
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[React.Event.Activated] = function()
					props.navigation.navigate(clickTargetPageName)
				end,
			})
		end
	end

	describe("SwitchNavigator Tests", function()
		it("should change pages on navigate operation", function()
			local navigator = RoactNavigation.createRobloxSwitchNavigator({
				{ PageOne = createButtonPage("PageOne", "PageTwo") },
				{ PageTwo = createButtonPage("PageTwo", "PageOne") },
			})
			local appContainer = React.createElement(RoactNavigation.createAppContainer(navigator), {
				detached = true,
			})

			local screen = createScreenGui(CoreGui)

			local root = ReactRoblox.createRoot(screen)
			ReactRoblox.act(function()
				root:render(appContainer)
			end)

			local appPath = XPath.new(screen):cat(XPath.new("View"))
			local buttonPath = appPath:cat(XPath.new("card_PageOne.Scene"))
			local buttonElement = Element.new(buttonPath)

			expect(buttonElement:waitForRbxInstance(1)).to.be.ok()
			expect(buttonElement:getText()).to.equal("PageOne")

			ReactRoblox.act(function()
				buttonElement:click()
			end)

			local button2Path = appPath:cat(XPath.new("card_PageTwo.Scene"))
			local newButtonElement = Element.new(button2Path)
			expect(newButtonElement:waitForRbxInstance(1)).to.be.ok()
			expect(newButtonElement:getText()).to.equal("PageTwo")

			ReactRoblox.act(function()
				root:unmount()
			end)
		end)
	end)
end
