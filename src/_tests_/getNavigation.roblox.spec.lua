return function()
	local RoactNavigationModule = script.Parent.Parent
	local Events = require(RoactNavigationModule.Events)
	local getNavigation = require(RoactNavigationModule.getNavigation)
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestGlobals).expect

	local function makeTestBundle(testState)
		testState = testState or {
			routes = {
				{ key = "a" }
			},
			index = 1,
		}

		local testActions = {}
		local bundle = {
			testActions = testActions,
			testState = testState,
			testRouter = {
				getActionCreators = function()
					return testActions
				end
			},
			testDispatch = function() end,
			testActionSubscribers = {},
			testGetScreenProps = function() end,
		} :: any

		function bundle.testGetCurrentNavigation()
			return bundle.navigation
		end

		bundle.navigation = getNavigation(
			bundle.testRouter,
			bundle.testState,
			bundle.testDispatch,
			bundle.testActionSubscribers,
			bundle.testGetScreenProps,
			bundle.testGetCurrentNavigation
		)

		return bundle
	end

	it("should build out correct public props", function()
		local bundle = makeTestBundle()

		jestExpect(bundle.navigation.actions).toBe(bundle.testActions)
		jestExpect(bundle.navigation.router).toBe(bundle.testRouter)
		jestExpect(bundle.navigation.state).toBe(bundle.testState)
		jestExpect(bundle.navigation.dispatch).toBe(bundle.testDispatch)
		jestExpect(bundle.navigation.getScreenProps).toBe(bundle.testGetScreenProps)
		jestExpect(#bundle.navigation._childrenNavigation).toEqual(0)
	end)

	describe("isFocused tests", function()
		it("should return focused=true for child key matching index", function()
			local bundle = makeTestBundle()
			jestExpect(bundle.navigation.isFocused("a")).toEqual(true)
		end)

		it("should return focused=false for child key not matching index", function()
			local bundle = makeTestBundle({
				routes = {
					{ key = "a" },
					{ key = "b" },
				},
				index = 2,
			})
			jestExpect(bundle.navigation.isFocused("a")).toEqual(false)
		end)

		it("should return focused=true if no child key provided (parent always focused)", function()
			local bundle = makeTestBundle()
			jestExpect(bundle.navigation.isFocused()).toEqual(true)
		end)
	end)

	describe("addListener tests", function()
		it("should short-circuit subscriptions for non-Action events", function()
			local bundle = makeTestBundle()

			local testHandler = function() end
			bundle.navigation.addListener(Events.WillFocus, testHandler)
			jestExpect(bundle.testActionSubscribers[testHandler]).toBeNil()
		end)

		it("should add Action event handlers to actionSubscribers set", function()
			local bundle = makeTestBundle()

			local testHandler = function() end
			bundle.navigation.addListener(Events.Action, testHandler)
			jestExpect(bundle.testActionSubscribers[testHandler]).toEqual(true)
		end)
	end)
end
