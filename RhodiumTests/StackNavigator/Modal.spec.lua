return function()
	local CoreGui = game:GetService("CoreGui")

	local RhodiumTests = script.Parent.Parent
	local Packages = RhodiumTests.Parent.Packages
	local Storybook = Packages.RoactNavigationStorybook
	local Element = Rhodium.Element
	local XPath = Rhodium.XPath

	local SimpleModalStackNavigator = require(Storybook.StackNavigator["SimpleModalStackNavigator.story"])

	local createScreenGui = require(RhodiumTests.createScreenGui)
	local TrackRobloxStackNavigatorRoute = require(RhodiumTests.TrackRobloxStackNavigatorRoute)

	local screen = nil
	local trackNavigator = nil
	local deleteScreenGui = nil

	local mainRoute = "MainContent"
	local modalRoute = "ModalDialog"

	beforeEach(function()
		screen = createScreenGui(CoreGui)
		trackNavigator = TrackRobloxStackNavigatorRoute.new()
		deleteScreenGui = SimpleModalStackNavigator(screen, {
			onTransitionEnd = trackNavigator.onTransitionEnd,
		})
	end)

	afterEach(function()
		deleteScreenGui()
	end)

	it("dismisses a dialog", function()
		local showModalButtonInstance = screen:FindFirstChild("showModalButton", true)
		expect(showModalButtonInstance).to.be.ok()
		local showModalButton = Element.new(showModalButtonInstance)

		showModalButton:click()
		trackNavigator:waitForRoute(modalRoute)

		local rootPath = XPath.new(screen)
		local scenesPath = rootPath:cat(XPath.new("View.TransitionerScenes"))
		local dialogPath = scenesPath:cat(XPath.new("2.DynamicContent.*.Scene.dialog"))

		local dismissDialog = Element.new(dialogPath:cat(XPath.new("dismissModalButton")))
		expect(dismissDialog:getRbxInstance()).to.be.ok()

		dismissDialog:click()

		trackNavigator:waitForRoute(mainRoute)

		expect(Element.new(dialogPath):getRbxInstance()).never.to.be.ok()
	end)

	it("can popToTop after pushing two dialogs", function()
		local showModalButtonInstance = screen:FindFirstChild("showModalButton", true)
		expect(showModalButtonInstance).to.be.ok()
		local showModalButton = Element.new(showModalButtonInstance)

		showModalButton:click()
		trackNavigator:waitForRoute(modalRoute)

		local rootPath = XPath.new(screen)
		local scenesPath = rootPath:cat(XPath.new("View.TransitionerScenes"))
		local dialogPath = scenesPath:cat(XPath.new("2.DynamicContent.*.Scene.dialog"))

		local pushDialog = Element.new(dialogPath:cat(XPath.new("pushAnotherModalButton")))

		pushDialog:click()

		trackNavigator:waitForRoute(modalRoute, {
			dialogCount = 1,
		})

		local secondDialogPath = scenesPath:cat(XPath.new("3.DynamicContent.*.Scene.dialog"))
		local popToTop = Element.new(secondDialogPath:cat(XPath.new("popToTopModalButton")))

		popToTop:click()

		trackNavigator:waitForRoute(mainRoute)

		expect(Element.new(dialogPath):getRbxInstance()).never.to.be.ok()
		expect(Element.new(secondDialogPath):getRbxInstance()).never.to.be.ok()
	end)

	it("can dismiss each dialog after pushing two dialogs", function()
		local showModalButtonInstance = screen:FindFirstChild("showModalButton", true)
		expect(showModalButtonInstance).to.be.ok()
		local showModalButton = Element.new(showModalButtonInstance)

		showModalButton:click()
		trackNavigator:waitForRoute(modalRoute)

		local rootPath = XPath.new(screen)
		local scenesPath = rootPath:cat(XPath.new("View.TransitionerScenes"))

		local dialogPath = scenesPath:cat(XPath.new("2.DynamicContent.*.Scene.dialog"))
		local pushDialog = Element.new(dialogPath:cat(XPath.new("pushAnotherModalButton")))
		pushDialog:click()

		trackNavigator:waitForRoute(modalRoute, {
			dialogCount = 1,
		})

		local secondDialogPath = scenesPath:cat(XPath.new("3.DynamicContent.*.Scene.dialog"))
		local dismissSecondDialog = Element.new(secondDialogPath:cat(XPath.new("dismissModalButton")))
		dismissSecondDialog:click()

		trackNavigator:waitForRoute(modalRoute, {})
		expect(Element.new(secondDialogPath):getRbxInstance()).never.to.be.ok()

		local dismissFirstDialog = Element.new(dialogPath:cat(XPath.new("dismissModalButton")))
		dismissFirstDialog:click()

		trackNavigator:waitForRoute(mainRoute)

		expect(Element.new(dialogPath):getRbxInstance()).never.to.be.ok()
	end)

	it("pushes, pops, pushes again and go back", function()
		for _, buttonName in ipairs({ "popToTopModalButton", "dismissModalButton" }) do
			local showModalButtonInstance = screen:FindFirstChild("showModalButton", true)
			expect(showModalButtonInstance).to.be.ok()
			local showModalButton = Element.new(showModalButtonInstance)

			showModalButton:click()
			trackNavigator:waitForRoute(modalRoute)

			local rootPath = XPath.new(screen)
			local scenesPath = rootPath:cat(XPath.new("View.TransitionerScenes"))
			local dialogPath = scenesPath:cat(XPath.new("2.DynamicContent.*.Scene.dialog"))

			local button = Element.new(dialogPath:cat(XPath.new(buttonName)))

			button:click()

			trackNavigator:waitForRoute(mainRoute)

			expect(Element.new(dialogPath):getRbxInstance()).never.to.be.ok()
		end
	end)
end
