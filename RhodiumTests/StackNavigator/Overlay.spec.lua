return function()
	local CoreGui = game:GetService("CoreGui")

	local Packages = script.Parent.Parent.Parent.Packages
	local Storybook = Packages.RoactNavigationStorybook
	local Element = Rhodium.Element
	local XPath = Rhodium.XPath

	local SimpleOverlay = require(Storybook.StackNavigator["SimpleOverlayStackNavigator.story"])
	local OverlayThatDoesNotAbsorbInput =
		require(Storybook.StackNavigator["OverlayStackNavigatorThatDoesNotAbsorbInput.story"])

	local TrackRobloxStackNavigatorRoute = require(script.Parent.Parent.TrackRobloxStackNavigatorRoute)
	local createScreenGui = require(script.Parent.Parent.createScreenGui)

	describe("simple overlay stack navigator", function()
		local function getAndVerifyOverlay(scenePath)
			local overlayPath = scenePath:cat(XPath.new("DynamicContent.*.Scene.dialog"))
			local overlay = Element.new(overlayPath)

			expect(overlay:waitForRbxInstance(1)).to.be.ok()

			local dismiss = Element.new(overlayPath:cat(XPath.new("dismissOverlayButton")))
			local popToTop = Element.new(overlayPath:cat(XPath.new("popToTopOverlayButton")))
			local pushOverlay = Element.new(overlayPath:cat(XPath.new("pushAnotherOverlayButton")))

			expect(dismiss:waitForRbxInstance(1)).to.be.ok()
			expect(popToTop:waitForRbxInstance(1)).to.be.ok()
			expect(pushOverlay:waitForRbxInstance(1)).to.be.ok()

			return {
				dismiss = dismiss,
				popToTop = popToTop,
				pushOverlay = pushOverlay,
			}
		end

		it("should navigate through pages", function()
			local screen = createScreenGui(CoreGui)
			local trackNavigator = TrackRobloxStackNavigatorRoute.new()
			local delete = SimpleOverlay(screen, {
				onTransitionEnd = trackNavigator.onTransitionEnd,
			})

			local rootPath = XPath.new("game.CoreGui"):cat(XPath.new(screen.Name))
			local scenesPath = rootPath:cat(XPath.new("View.TransitionerScenes"))
			local showOverlayButtonPath = XPath.new("1.DynamicContent.*.Scene.showOverlayButton")

			local showOverlayButton = Element.new(scenesPath:cat(showOverlayButtonPath))

			expect(showOverlayButton:waitForRbxInstance(1)).to.be.ok()

			showOverlayButton:click()

			local overlayRoute = "OverlayDialog"
			local mainRoute = "MainContent"

			trackNavigator:waitForRoute(overlayRoute)

			do
				local firstOverlayPath = scenesPath:cat(XPath.new("2"))
				local firstOverlay = getAndVerifyOverlay(firstOverlayPath)

				firstOverlay.dismiss:click()

				trackNavigator:waitForRoute(mainRoute)

				local firstOverlayElement = Element.new(firstOverlayPath)
				expect(firstOverlayElement:getRbxInstance()).never.to.be.ok()
			end

			showOverlayButton:click()
			trackNavigator:waitForRoute(overlayRoute)

			do
				local firstOverlayPath = scenesPath:cat(XPath.new("2"))
				local firstOverlay = getAndVerifyOverlay(firstOverlayPath)

				firstOverlay.pushOverlay:click()
				trackNavigator:waitForRoute(overlayRoute, { dialogCount = 1 })

				local secondOverlayPath = scenesPath:cat(XPath.new("3"))
				local secondOverlay = getAndVerifyOverlay(secondOverlayPath)

				secondOverlay.dismiss:click()
				trackNavigator:waitForRoute(overlayRoute, {})

				local secondOverlayElement = Element.new(secondOverlayPath)
				expect(secondOverlayElement:getRbxInstance()).never.to.be.ok()

				local firstOverlayElement = Element.new(firstOverlayPath)
				expect(firstOverlayElement:getRbxInstance()).to.be.ok()

				firstOverlay.pushOverlay:click()
				trackNavigator:waitForRoute(overlayRoute, { dialogCount = 1 })

				secondOverlay = getAndVerifyOverlay(secondOverlayPath)
				secondOverlay.pushOverlay:click()
				trackNavigator:waitForRoute(overlayRoute, { dialogCount = 2 })

				local thirdOverlayPath = scenesPath:cat(XPath.new("4"))
				local thirdOverlay = getAndVerifyOverlay(thirdOverlayPath)

				thirdOverlay.popToTop:click()
				trackNavigator:waitForRoute(mainRoute)

				firstOverlayElement = Element.new(firstOverlayPath)
				expect(firstOverlayElement:getRbxInstance()).never.to.be.ok()
				secondOverlayElement = Element.new(secondOverlayPath)
				expect(secondOverlayElement:getRbxInstance()).never.to.be.ok()
				local thirdOverlayElement = Element.new(thirdOverlayPath)
				expect(thirdOverlayElement:getRbxInstance()).never.to.be.ok()
			end

			delete()
			screen:Destroy()
		end)
	end)

	describe("overlay stack navigator that does not absorb input", function()
		local function getAndVerifyOverlay(scenePath)
			local overlayPath = scenePath:cat(XPath.new("DynamicContent.*.Scene.dialog"))
			local overlay = Element.new(overlayPath)

			expect(overlay:waitForRbxInstance(1)).to.be.ok()

			local pushOverlay = Element.new(overlayPath:cat(XPath.new("pushAnotherOverlayButton")))

			expect(pushOverlay:waitForRbxInstance(1)).to.be.ok()

			return {
				pushOverlay = pushOverlay,
			}
		end

		it("should not throw when going back without any dialogs", function()
			local screen = createScreenGui(CoreGui)
			local trackNavigator = TrackRobloxStackNavigatorRoute.new()
			local delete = OverlayThatDoesNotAbsorbInput(screen, {
				onTransitionEnd = trackNavigator.onTransitionEnd,
			})

			local rootPath = XPath.new("game.CoreGui"):cat(XPath.new(screen.Name))
			local scenesPath = rootPath:cat(XPath.new("View.TransitionerScenes"))

			local mainContent = scenesPath:cat(XPath.new("1.DynamicContent.*.Scene"))
			local showOverlayButton = Element.new(mainContent:cat(XPath.new("showOverlayButton")))
			local goToMain = Element.new(mainContent:cat(XPath.new("goBackPassThroughButton")))

			expect(showOverlayButton:waitForRbxInstance(1)).to.be.ok()
			expect(goToMain:waitForRbxInstance(1)).to.be.ok()

			goToMain:click()

			expect(showOverlayButton:getRbxInstance()).to.be.ok()
			expect(goToMain:getRbxInstance()).to.be.ok()

			delete()
			screen:Destroy()
		end)

		it("should navigate through pages", function()
			local screen = createScreenGui(CoreGui)
			local trackNavigator = TrackRobloxStackNavigatorRoute.new()
			local delete = OverlayThatDoesNotAbsorbInput(screen, {
				onTransitionEnd = trackNavigator.onTransitionEnd,
			})

			local rootPath = XPath.new("game.CoreGui"):cat(XPath.new(screen.Name))
			local scenesPath = rootPath:cat(XPath.new("View.TransitionerScenes"))

			local mainContent = scenesPath:cat(XPath.new("1.DynamicContent.*.Scene"))
			local showOverlayButton = Element.new(mainContent:cat(XPath.new("showOverlayButton")))
			local goToMain = Element.new(mainContent:cat(XPath.new("goBackPassThroughButton")))

			expect(showOverlayButton:waitForRbxInstance(1)).to.be.ok()
			expect(goToMain:waitForRbxInstance(1)).to.be.ok()

			showOverlayButton:click()

			local overlayRoute = "OverlayDialog"
			local mainRoute = "MainContent"

			trackNavigator:waitForRoute(overlayRoute)

			local firstOverlayPath = scenesPath:cat(XPath.new("2"))
			local firstOverlay = getAndVerifyOverlay(firstOverlayPath)

			firstOverlay.pushOverlay:click()
			trackNavigator:waitForRoute(overlayRoute, { dialogCount = 1 })

			local secondOverlayPath = scenesPath:cat(XPath.new("3"))
			getAndVerifyOverlay(secondOverlayPath)

			goToMain:click()
			trackNavigator:waitForRoute(mainRoute)

			local firstOverlayElement = Element.new(firstOverlayPath)
			expect(firstOverlayElement:getRbxInstance()).never.to.be.ok()
			local secondOverlayElement = Element.new(secondOverlayPath)
			expect(secondOverlayElement:getRbxInstance()).never.to.be.ok()

			delete()
			screen:Destroy()
		end)
	end)
end
