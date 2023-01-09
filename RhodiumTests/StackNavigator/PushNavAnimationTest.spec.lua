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
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Size = UDim2.new(1, 0, 1, 0),
				Text = pageName,
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[React.Event.Activated] = function()
					props.navigation.navigate(clickTargetPageName)
				end,
			})
		end
	end

	describe("StackNavigator Tests", function()
		it("should animate page change on navigate operation", function()
			local navigator = RoactNavigation.createRobloxStackNavigator({
				{ PageOne = createButtonPage("PageOne", "PageTwo") },
				{ PageTwo = createButtonPage("PageTwo", "PageOne") },
			})
			local appContainer = React.createElement(RoactNavigation.createAppContainer(navigator), {
				detached = true,
			})

			local screen = createScreenGui(CoreGui)
			local rootPath = XPath.new(screen):cat(XPath.new("View.TransitionerScenes"))
			local scene1Path = rootPath:cat(XPath.new("1.DynamicContent.*.Scene"))
			local scene2Path = rootPath:cat(XPath.new("2.DynamicContent.*.Scene"))

			local root = ReactRoblox.createRoot(screen)
			ReactRoblox.act(function()
				root:render(appContainer)
			end)

			local button1Element = Element.new(scene1Path)
			expect(button1Element:waitForRbxInstance(1)).to.be.ok()
			expect(button1Element:getText()).to.equal("PageOne")

			ReactRoblox.act(function()
				button1Element:click()
			end)

			local scene2ButtonElement = Element.new(scene2Path)
			expect(scene2ButtonElement:waitForRbxInstance(1)).to.be.ok()
			expect(scene2ButtonElement:getText()).to.equal("PageTwo")

			ReactRoblox.act(function()
				root:unmount()
			end)
		end)
	end)
end
