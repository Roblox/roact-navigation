return function()
	local views = script.Parent.Parent
	local Packages = views.Parent.Parent

	local SceneView = require(views.SceneView)
	local React = require(Packages.React)
	local ReactRoblox = require(Packages.Dev.ReactRoblox)
	local JestGlobals = require(Packages.Dev.JestGlobals)
	local expect = JestGlobals.expect

	it("should mount inner component and pass down required props+context.navigation", function()
		local testComponentNavigationFromProp = nil
		local testComponentScreenProps = nil

		local TestComponent = React.Component:extend("TestComponent")
		function TestComponent:render()
			testComponentNavigationFromProp = self.props.navigation
			testComponentScreenProps = self.props.screenProps
			return nil
		end

		local testScreenProps = {}
		local testNav = {}
		local element = React.createElement(SceneView, {
			screenProps = testScreenProps,
			navigation = testNav,
			component = TestComponent,
		})

		local parent = Instance.new("Folder")
		local root = ReactRoblox.createRoot(parent)
		ReactRoblox.act(function()
			root:render(element)
		end)
		ReactRoblox.act(function()
			root:unmount()
		end)

		expect(testComponentScreenProps).toBe(testScreenProps)
		expect(testComponentNavigationFromProp).toBe(testNav)
	end)
end
