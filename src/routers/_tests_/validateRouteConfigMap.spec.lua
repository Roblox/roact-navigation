return function()
	local routersModule = script.Parent.Parent
	local RoactNavigationModule = routersModule.Parent
	local Packages = RoactNavigationModule.Parent
	local Roact = require(Packages.Roact)
	local jestExpect = require(Packages.Dev.JestGlobals).expect

	local validateRouteConfigMap = require(routersModule.validateRouteConfigMap)

	local TestComponent = Roact.Component:extend("TestComponent")
	function TestComponent:render()
		return nil
	end

	local INVALID_COMPONENT_MESSAGE = "The component for route 'myRoute' must be a Roact" ..
		" component or table with 'getScreen'."

	it("should throw if routeConfigs is not a table", function()
		jestExpect(function()
			validateRouteConfigMap(5)
		end).toThrow("routeConfigs must be a table")
	end)

	it("should throw if routeConfigs is empty", function()
		jestExpect(function()
			validateRouteConfigMap({})
		end).toThrow("Please specify at least one route when configuring a navigator.")
	end)

	it("should throw if routeConfigs contains an invalid Roact element", function()
		jestExpect(function()
			validateRouteConfigMap({
				myRoute = 5,
			})
		end).toThrow()
	end)

	it("should throw when both screen and getScreen are provided for same component", function()
		jestExpect(function()
			validateRouteConfigMap({
				myRoute = {
					screen = "TheScreen",
					getScreen = function() return TestComponent end,
				}
			})
		end).toThrow("Route 'myRoute' should declare a screen or a getScreen, not both.")
	end)

	it("should throw for a simple table where screen is not a Roact component", function()
		jestExpect(function()
			validateRouteConfigMap({
				myRoute = {
					screen = {},
				}
			})
		end).toThrow(INVALID_COMPONENT_MESSAGE)
	end)

	it("should throw for a non-function getScreen", function()
		jestExpect(function()
			validateRouteConfigMap({
				myRoute = {
					getScreen = 5
				}
			})
		end).toThrow(INVALID_COMPONENT_MESSAGE)
	end)

	it("should throw for a Host Component", function()
		jestExpect(function()
			validateRouteConfigMap({
				myRoute = {
					aFrame = "Frame"
				}
			})
		end).toThrow(INVALID_COMPONENT_MESSAGE)
	end)

	it("should pass for valid basic routeConfigs", function()
		validateRouteConfigMap({
			basicComponentRoute = TestComponent,
			functionalComponentRoute = function() end,
		})
	end)

	it("should pass for valid screen prop type routeConfigs", function()
		validateRouteConfigMap({
			basicComponentRoute = {
				screen = TestComponent,
			},
			functionalComponentRoute = {
				screen = function() end,
			},
		})
	end)

	it("should pass for valid getScreen route configs", function()
		validateRouteConfigMap({
			getScreenRoute = {
				getScreen = function() return TestComponent end,
			}
		})
	end)
end
