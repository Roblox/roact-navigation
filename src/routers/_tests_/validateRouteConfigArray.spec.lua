return function()
	local routersModule = script.Parent.Parent
	local RoactNavigationModule = routersModule.Parent
	local Packages = RoactNavigationModule.Parent
	local Roact = require(Packages.Roact)
	local jestExpect = require(Packages.Dev.JestRoblox).Globals.expect

	local validateRouteConfigArray = require(routersModule.validateRouteConfigArray)

	local TestComponent = Roact.Component:extend("TestComponent")
	function TestComponent:render()
		return nil
	end

	it("should throw if routeConfigs is not a table", function()
		jestExpect(function()
			validateRouteConfigArray(5)
		end).toThrow("routeConfigs must be an array table")
	end)

	it("should throw if routeConfigs is empty", function()
		jestExpect(function()
			validateRouteConfigArray({})
		end).toThrow("Please specify at least one route when configuring a navigator")
	end)

	it("should throw if routeConfigs contains an invalid Roact element", function()
		jestExpect(function()
			validateRouteConfigArray({
				{ myRoute = 5 },
			})
		end).toThrow(
			"The component for route 'myRoute' must be a Roact Function/Stateful"
				.. " component or table with 'getScreen'.getScreen function must return Roact"
				.. " Function/Stateful component"
		)
	end)

	it("should throw if getScreen returns invalid Roact element", function()
		jestExpect(function()
			validateRouteConfigArray({
				{ myRoute = { getScreen = function() end } },
			})
		end).toThrow(
			"The component for route 'myRoute' must be a Roact Function/Stateful"
				.. " component or table with 'getScreen'.getScreen function must return Roact"
				.. " Function/Stateful component"
		)
	end)

	it("should throw when both screen and getScreen are provided for same component", function()
		jestExpect(function()
			validateRouteConfigArray({
				{myRoute = {
					screen = "TheScreen",
					getScreen = function() return TestComponent end,
				}}
			})
		end).toThrow("Route 'myRoute' should provide 'screen' or 'getScreen', but not both")
	end)

	it("should throw for a simple table where screen is not a Roact Function/Stateful component", function()
		jestExpect(function()
			validateRouteConfigArray({
				{ myRoute = { screen = {} } },
			})
		end).toThrow(
			"The component for route 'myRoute' must be a Roact Function/Stateful"
				.. " component or table with 'getScreen'.getScreen function must return Roact"
				.. " Function/Stateful component"
		)
	end)

	it("should throw for a non-function getScreen", function()
		jestExpect(function()
			validateRouteConfigArray({
				{ myRoute = { getScreen = 5 } },
			})
		end).toThrow(
			"The component for route 'myRoute' must be a Roact Function/Stateful"
				.. " component or table with 'getScreen'.getScreen function must return"
				.. " Roact Function/Stateful component"
		)
	end)

	it("should throw for a Host Component", function()
		jestExpect(function()
			validateRouteConfigArray({
				{ myRoute = { aFrame = "Frame" } },
			})
		end).toThrow(
			"The component for route 'myRoute' must be a Roact Function/Stateful"
				.. " component or table with 'getScreen'.getScreen function must return Roact"
				.. " Function/Stateful component"
		)
	end)

	it("should throw if routeConfig is a map", function()
		local key = "basicComponentRoute"
		local message = ("routeConfigs must be an array table (found non-number key %q of type %q"):format(
			key,
			type(key)
		)
		jestExpect(function()
			validateRouteConfigArray({
				[key] = TestComponent,
			})
		end).toThrow(message)
	end)

	it("should throw if there is more than one route in each array entry", function()
		jestExpect(function()
			validateRouteConfigArray({
				{ aRouteName = TestComponent, anotherRoute = TestComponent },
			})
		end).toThrow("only one route must be defined in each entry (found multiple at index 1)")
	end)

	it("should pass for valid basic routeConfigs", function()
		validateRouteConfigArray({
			{ basicComponentRoute = TestComponent },
			{ functionalComponentRoute = function() end },
		})
	end)

	it("should pass for valid screen prop type routeConfigs", function()
		validateRouteConfigArray({
			{ basicComponentRoute = { screen = TestComponent } },
			{ functionalComponentRoute = { screen = function() end } },
		})
	end)

	it("should pass for valid getScreen route configs", function()
		validateRouteConfigArray({
			{ getScreenRoute = { getScreen = function() return TestComponent end } },
		})
	end)
end
