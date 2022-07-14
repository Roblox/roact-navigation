return function()
	local viewsModule = script.Parent.Parent
	local RoactNavigationModule = viewsModule.Parent
	local Packages = RoactNavigationModule.Parent

	local React = require(Packages.React)
	local ReactRoblox = require(Packages.Dev.ReactRoblox)
	local useNavigation = require(viewsModule.useNavigation)
	local NavigationContext = require(viewsModule.NavigationContext)

	local jestExpect = require(Packages.Dev.JestGlobals).expect

	local function defaultMockNavigation()
		return {
			isFocused = function() return false end,
			addListener = function()
				return {
					remove = function() end,
				}
			end,
			getParam = function() return nil end,
			navigate = function() end,
			state = {
				routeName = "DummyRoute",
			},
		}
	end

	local function renderWithNavigationProvider(element, navigation: any?)
		navigation = navigation or defaultMockNavigation()
		return React.createElement(NavigationContext.Provider, {
			value = navigation,
		}, {
			Child = element,
		})
	end

	it("it should provide the navigation prop", function()
		local navigation
		local function NavigationHookComponent()
			navigation = useNavigation()
		end

		local element = React.createElement(NavigationHookComponent)
		element = renderWithNavigationProvider(element)

		local container = Instance.new("Frame")
		local root = ReactRoblox.createRoot(container)

		ReactRoblox.act(function()
			root:render(element)
		end)

		jestExpect(navigation).toMatchObject({
			navigate = jestExpect.any("function"),
		})
		root:unmount()
	end)
end
