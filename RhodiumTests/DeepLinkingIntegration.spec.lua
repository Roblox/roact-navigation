return function()
	local CoreGui = game:GetService("CoreGui")

	local RhodiumTests = script.Parent
	local Packages = RhodiumTests.Parent.Packages
	local Storybook = Packages.RoactNavigationStorybook
	local Element = Rhodium.Element
	local XPath = Rhodium.XPath

	local createDeepLinkingIntegration = require(Storybook["DeepLinkingIntegration.story"])
	local createLinkingProtocolMock = require(Storybook.createLinkingProtocolMock)
	local createScreenGui = require(RhodiumTests.createScreenGui)

	local screen = nil

	beforeEach(function()
		screen = createScreenGui(CoreGui)
	end)

	afterEach(function()
		screen:Destroy()
	end)

	-- helper to assert that the profile page correctly mounted in the instance hierarchy
	-- if the `expectedTitle` param is not provided, it will assert that the default
	-- empty profile page is mounted
	local function assertProfilePage(expect, expectedTitle)
		local view = screen:FindFirstChild("View")
		local scenes = view:FindFirstChild("TransitionerScenes")
		expect(scenes).to.be.ok()

		local profileScreen = scenes:FindFirstChild(expectedTitle and "2" or "1")
		expect(profileScreen).to.be.ok()
		local profileTitle = profileScreen:FindFirstChild("PageLabel", true)
		expect(profileTitle).to.be.ok()
		expect(profileTitle.Text).to.equal(expectedTitle or "No user is specified")
	end

	describe("default url = `login`", function()
		local linkingProtocolMock = nil
		local deleteScreenGui = nil

		beforeEach(function()
			linkingProtocolMock = createLinkingProtocolMock("login")
			deleteScreenGui = createDeepLinkingIntegration(screen, linkingProtocolMock)
		end)

		afterEach(function()
			deleteScreenGui()
			linkingProtocolMock = nil
		end)

		it("navigates to the profile page", function()
			local loginTitle = Element.new(XPath.new("Scene.PageLabel", screen))
			expect(loginTitle:getRbxInstance().Text).to.equal("Login screen")

			linkingProtocolMock.callback("profile/cranberry")

			assertProfilePage(expect, "cranberry Profile")
		end)
	end)

	describe("default url = `profile/sponge`", function()
		local linkingProtocolMock = nil
		local deleteScreenGui = nil

		beforeEach(function()
			linkingProtocolMock = createLinkingProtocolMock("profile/sponge")
			deleteScreenGui = createDeepLinkingIntegration(screen, linkingProtocolMock)
		end)

		afterEach(function()
			deleteScreenGui()
			linkingProtocolMock = nil
		end)

		it("is on the correct profile page initially", function()
			assertProfilePage(expect, "sponge Profile")
		end)

		it("navigates to a new profile page", function()
			linkingProtocolMock.callback("profile/telescope")
			assertProfilePage(expect, "telescope Profile")
		end)

		it("navigates back to the login page", function()
			linkingProtocolMock.callback("login")

			local loginTitle = Element.new(XPath.new("Scene.PageLabel", screen))
			expect(loginTitle:getRbxInstance().Text).to.equal("Login screen")
		end)

		it("navigates to the empty profile page", function()
			linkingProtocolMock.callback("profile")

			assertProfilePage(expect)
		end)
	end)
end
