return function()
	local navigatorsModule = script.Parent.Parent
	local RoactNavigationModule = navigatorsModule.Parent
	local routersModule = RoactNavigationModule.routers
	local viewsModule = RoactNavigationModule.views
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestGlobals).expect
	local React = require(Packages.React)
	local ReactRoblox = require(Packages.Dev.ReactRoblox)

	local createNavigator = require(navigatorsModule.createNavigator)
	local createAppContainer = require(RoactNavigationModule.createAppContainer).createAppContainer
	local StackRouter = require(routersModule.StackRouter)
	local StackView = require(viewsModule.RobloxStackView.StackView)

	local testRouter = {
		getScreenOptions = function()
			return nil
		end,
	}

	local root = nil
	beforeEach(function()
		local parent = Instance.new("Folder")
		root = ReactRoblox.createRoot(parent)
	end)

	afterEach(function()
		root:unmount()
		root = nil
	end)

	it("should return a Roact component that exposes navigator fields", function()
		local testComponentMounted = nil
		local TestViewComponent = React.Component:extend("TestViewComponent")
		function TestViewComponent:render() end
		function TestViewComponent:didMount()
			testComponentMounted = true
		end
		function TestViewComponent:willUnmount()
			testComponentMounted = false
		end

		local testNavOptions = {}

		local navigator = createNavigator(TestViewComponent, testRouter, {
			navigationOptions = testNavOptions,
		})

		jestExpect(navigator.render).toEqual(jestExpect.any("function"))
		jestExpect(navigator.router).toBe(testRouter)
		jestExpect(navigator.navigationOptions).toBe(testNavOptions)

		local testNavigation = {
			state = {
				routes = {
					{ routeName = "Foo", key = "Foo" },
				},
				index = 1,
			},
			getChildNavigation = function()
				return nil
			end, -- stub
			addListener = function() end,
		}

		ReactRoblox.act(function()
			root:render(React.createElement(navigator, {
				navigation = testNavigation,
			}))
		end)

		jestExpect(testComponentMounted).toEqual(true)
		ReactRoblox.act(function()
			root:unmount()
		end)
		jestExpect(testComponentMounted).toEqual(false)
	end)

	it("should throw when trying to mount without navigation prop", function()
		local TestViewComponent = function() end

		local navigator = createNavigator(TestViewComponent, testRouter, {
			navigationOptions = {},
		})

		jestExpect(function()
			ReactRoblox.act(function()
				root:render(React.createElement(navigator))
			end)
		end).toThrow("The navigation prop is missing for this navigator")
	end)

	it("should throw when trying to mount without routes", function()
		local TestViewComponent = function() end

		local navigator = createNavigator(TestViewComponent, testRouter, {
			navigationOptions = {},
		})

		local testNavigation = {
			state = {
				index = 1,
			},
			getChildNavigation = function()
				return nil
			end, -- stub
		}

		jestExpect(function()
			ReactRoblox.act(function()
				root:render(React.createElement(navigator, {
					navigation = testNavigation,
				}))
			end)
		end).toThrow('No "routes" found in navigation state')
	end)

	it("should not throw when navigating back for very deeply nested navigators", function()
		local function NavigateTo(page)
			return function(props)
				React.useEffect(function()
					props.navigation.push(page)
				end, {})

				return nil
			end
		end

		local function GoBack(props)
			React.useEffect(function()
				props.navigation.goBack()
			end, {})

			return nil
		end

		local function RapidlyUpdatingStackView(props)
			local startTime = React.useState(tick())
			local screenProps, setScreenProps = React.useState({})

			React.useEffect(function()
				if tick() - startTime < 5 then
					setScreenProps({}) -- Always create a new screenProps table so child always re-renders
				end
			end)

			return React.createElement(StackView, {
				navigation = props.navigation,
				descriptors = props.descriptors,
				navigationConfig = props.navigationConfig,
				screenProps = screenProps,
			})
		end

		local function createCustomStackNavigator(routeArray)
			local router = StackRouter(routeArray, {})
			return createNavigator(RapidlyUpdatingStackView, router, {})
		end

		local Navigator = createAppContainer(createCustomStackNavigator({
			{
				first1 = createCustomStackNavigator({
					{
						first2 = createCustomStackNavigator({
							{
								first3 = createCustomStackNavigator({
									{
										first4 = createCustomStackNavigator({
											{ first5 = NavigateTo("second") },
											{ second = GoBack },
										}),
									},
								}),
							},
						}),
					},
				}),
			},
		}))

		ReactRoblox.act(function()
			root:render(React.createElement(Navigator))
		end)
	end)
end
