return function()
	local CoreGui = game:GetService("CoreGui")

	local RhodiumTests = script.Parent
	local Packages = RhodiumTests.Parent.Packages
	local Storybook = Packages.RoactNavigationStorybook

	local Rhodium = require(Packages.Dev.Rhodium)
	local Element = Rhodium.Element
	local XPath = Rhodium.XPath

	local ReactRoblox = require(Packages.Dev.ReactRoblox)
	local JestGlobals = require(Packages.Dev.JestGlobals)
	local expect = JestGlobals.expect

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
	local function assertProfilePage(expectedTitle: string?)
		local view = screen:FindFirstChild("View")
		local scenes = view:FindFirstChild("TransitionerScenes")
		expect(scenes).toBeDefined()

		local profileScreen = scenes:FindFirstChild(if expectedTitle then "2" else "1")
		expect(profileScreen).toBeDefined()
		local profileTitle = profileScreen:FindFirstChild("PageLabel", true)
		expect(profileTitle).toBeDefined()
		expect(profileTitle.Text).toEqual(expectedTitle or "No user is specified")
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
			expect(loginTitle:getRbxInstance().Text).toEqual("Login screen")

			ReactRoblox.act(function()
				linkingProtocolMock.callback("profile/cranberry")
			end)

			assertProfilePage("cranberry Profile")
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
			assertProfilePage("sponge Profile")
		end)

		it("navigates to a new profile page", function()
			ReactRoblox.act(function()
				linkingProtocolMock.callback("profile/telescope")
			end)
			assertProfilePage("telescope Profile")
		end)

		it("navigates back to the login page", function()
			ReactRoblox.act(function()
				linkingProtocolMock.callback("login")
			end)

			local loginTitle = Element.new(XPath.new("Scene.PageLabel", screen))
			expect(loginTitle:getRbxInstance().Text).toEqual("Login screen")
		end)

		it("navigates to the empty profile page", function()
			ReactRoblox.act(function()
				linkingProtocolMock.callback("profile")
			end)

			assertProfilePage(nil)
		end)
	end)
end
