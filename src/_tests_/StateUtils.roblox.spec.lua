return function()
	local RoactNavigationModule = script.Parent.Parent
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestRoblox).Globals.expect

	local StateUtils = require(RoactNavigationModule.StateUtils)

	describe("StateUtils.get tests", function()
		it("should assert if state is not a table", function()
			jestExpect(function()
				StateUtils.get(nil, "key")
			end).toThrow()
		end)

		it("should assert if key is not a string", function()
			jestExpect(function()
				StateUtils.get({}, 5)
			end).toThrow()
		end)

		it("should return nil if key is not found in routes", function()
			local result = StateUtils.get({
				index = 1,
				routes = {
					{
						routeName = "foo",
						key = "foo-1",
					},
				},
			}, "key")

			jestExpect(result).toBeUndefined()
		end)

		it("should return route if key is found in routes", function()
			local result = StateUtils.get({
				index = 1,
				routes = {
					{
						routeName = "foo",
						key = "foo-1",
					}
				},
			}, "foo-1")

			jestExpect(result.routeName).toEqual("foo")
			jestExpect(result.key).toEqual("foo-1")
		end)
	end)

	describe("StateUtils.indexOf tests", function()
		it("should assert if state is not a table", function()
			jestExpect(function()
				StateUtils.indexOf(nil, "key")
			end).toThrow()
		end)

		it("should assert if key is not a string", function()
			jestExpect(function()
				StateUtils.indexOf({}, 5)
			end).toThrow()
		end)

		it("should return nil if key is not found in routes", function()
			local result = StateUtils.indexOf({
				index = 1,
				routes = {
					{
						routeName = "foo",
						key = "foo-1",
					}
				},
			}, "key")

			jestExpect(result).toBeUndefined()
		end)

		it("should return index if key is found in routes", function()
			local result = StateUtils.indexOf({
				index = 1,
				routes = {
					{
						routeName = "foo",
						key = "foo-1",
					},
					{
						routeName = "foo2",
						key = "foo-2",
					}
				},
			}, "foo-2")

			jestExpect(result).toEqual(2)
		end)
	end)

	describe("StateUtils.has tests", function()
		it("should assert if state is not a table", function()
			jestExpect(function()
				StateUtils.has(nil, "key")
			end).toThrow()
		end)

		it("should assert if key is not a string", function()
			jestExpect(function()
				StateUtils.has({}, 5)
			end).toThrow()
		end)

		it("should return false if key is not in routes", function()
			local result = StateUtils.has({
				index = 1,
				routes = {
					{
						routeName = "foo",
						key = "foo-1",
					}
				}
			}, "key")

			jestExpect(result).toEqual(false)
		end)

		it("should return true if key is found in routes", function()
			local result = StateUtils.has({
				index = 1,
				routes = {
					{
						routeName = "foo",
						key = "foo-1",
					}
				}
			}, "foo-1")

			jestExpect(result).toEqual(true)
		end)
	end)

	describe("StateUtils.push tests", function()
		it("should assert if state is not a table", function()
			jestExpect(function()
				StateUtils.push(nil, {})
			end).toThrow()
		end)

		it("should assert if route is not a table", function()
			jestExpect(function()
				StateUtils.push({}, 5)
			end).toThrow()
		end)

		it("should assert if route.key is already present", function()
			jestExpect(function()
				StateUtils.push({
					index = 1,
					routes = {
						{
							routeName = "foo",
							key = "foo-1",
						}
					}
				}, {
					routeName = "foo",
					key = "foo-1",
				})
			end).toThrow()
		end)

		it("should insert new route if it doesn't exist", function()
			local newState = StateUtils.push({
				index = 1,
				routes = {
					{
						routeName = "first",
						key = "foo-1",
					},
				},
			}, {
				routeName = "second",
				key = "foo-2",
			})

			jestExpect(newState.index).toEqual(2)
			jestExpect(#newState.routes).toEqual(2)
			jestExpect(newState.routes[newState.index].key).toEqual("foo-2")
			jestExpect(newState.routes[newState.index].routeName).toEqual("second")
		end)
	end)

	describe("StateUtils.pop tests", function()
		it("should assert if state is not a table", function()
			jestExpect(function()
				StateUtils.pop(nil)
			end).toThrow()
		end)

		it("should return existing state if routes is empty", function()
			local initialState = {
				index = 0,
				routes = {},
			}

			local newState = StateUtils.pop(initialState)
			jestExpect(newState).toEqual(initialState)
		end)

		it("should remove top route if popping with more than one route", function()
			local initialState = {
				index = 2,
				routes = {
					{ routeName = "route", key = "route-1", },
					{ routeName = "route", key = "route-2", },
				},
			}

			local newState = StateUtils.pop(initialState)
			jestExpect(newState.index).toEqual(1)
			jestExpect(#newState.routes).toEqual(1)
			jestExpect(newState.routes[1].key).toEqual("route-1")
		end)
	end)

	describe("StateUtils.jumpToIndex tests", function()
		it("should assert if state is not a table", function()
			jestExpect(function()
				StateUtils.jumpToIndex(nil, 0)
			end).toThrow()
		end)

		it("should assert if index is not a number", function()
			jestExpect(function()
				StateUtils.jumpToIndex({}, "foo")
			end).toThrow()
		end)

		it("should assert if index does not match a route", function()
			jestExpect(function()
				StateUtils.jumpToIndex({
					index = 1,
					routes = { { routeName = "first", key = "first-1" } }
				}, 5)
			end).toThrow()
		end)

		it("should return original state if index matches current", function()
			local initialState = {
				index = 1,
				routes = { { routeName = "one", key = "1" } }
			}

			local newState = StateUtils.jumpToIndex(initialState, 1)
			jestExpect(newState).toEqual(initialState)
		end)

		it("should return updated state if index differs", function()
			local initialState = {
				index = 1,
				routes = {
					{ routeName = "route", key = "route-1" },
					{ routeName = "route", key = "route-2" },
				},
			}

			local newState = StateUtils.jumpToIndex(initialState, 2)
			jestExpect(newState.index).toEqual(2)
		end)
	end)

	describe("StateUtils.jumpTo tests", function()
		it("should assert if state is not a table", function()
			jestExpect(function()
				StateUtils.jumpTo(nil, "key")
			end).toThrow()
		end)

		it("should assert if key is not a string", function()
			jestExpect(function()
				StateUtils.jumpTo({}, 0)
			end).toThrow()
		end)

		it("should return original state if key is already active route", function()
			local initialState = {
				index = 1,
				routes = {
					{ routeName = "route", key = "key-1" },
					{ routeName = "route", key = "key-2" },
				}
			}

			local newState = StateUtils.jumpTo(initialState, "key-1")
			jestExpect(newState).toBe(initialState)
		end)

		it("should return state with new active route if key is not active", function()
			local initialState = {
				index = 1,
				routes = {
					{ routeName = "route", key = "key-1" },
					{ routeName = "route", key = "key-2" },
				}
			}

			local newState = StateUtils.jumpTo(initialState, "key-2")
			jestExpect(newState.index).toEqual(2)
		end)
	end)

	describe("StateUtils.back tests", function()
		it("should assert if state is not a table", function()
			jestExpect(function()
				StateUtils.back(nil)
			end).toThrow()
		end)

		it("should return original state if route for new index does not exist", function()
			local initialState = {
				index = 1,
				routes = {
					{ routeName = "route", key = "key-1" },
				}
			}

			local newState = StateUtils.back(initialState)
			jestExpect(newState).toBe(initialState)
		end)

		it("should remove top state if there is somewhere to go", function()
			local initialState = {
				index = 2,
				routes = {
					{ routeName = "route", key = "key-1" },
					{ routeName = "route", key = "key-2" },
				}
			}

			local newState = StateUtils.back(initialState)
			jestExpect(newState.index).toEqual(1)
		end)
	end)

	describe("StateUtils.forward tests", function()
		it("should assert if state is not a table", function()
			jestExpect(function()
				StateUtils.forward(nil)
			end).toThrow()
		end)

		it("should not walk off the end of the route list", function()
			local initialState = {
				index = 1,
				routes = {
					{ routeName = "route", key = "key-1" },
				}
			}

			local newState = StateUtils.forward(initialState)
			jestExpect(newState).toBe(initialState)
		end)

		it("should move to next route if available", function()
			local initialState = {
				index = 1,
				routes = {
					{ routeName = "route", key = "key-1" },
					{ routeName = "route", key = "key-2" },
				}
			}

			local newState = StateUtils.forward(initialState)
			jestExpect(newState.index).toEqual(2)
		end)
	end)

	describe("StateUtils.replaceAndPrune tests", function()
		it("should assert if state is not a table", function()
			jestExpect(function()
				StateUtils.replaceAndPrune(nil, "key", {})
			end).toThrow()
		end)

		it("should assert if key is not a string", function()
			jestExpect(function()
				StateUtils.replaceAndPrune({}, 0, {})
			end).toThrow()
		end)

		it("should assert if route is not a table", function()
			jestExpect(function()
				StateUtils.replaceAndPrune({}, "key", 0)
			end).toThrow()
		end)

		it("should replace matching route and prune following routes", function()
			local initialState = {
				index = 2,
				routes = {
					{ routeName = "route", key = "key-1" },
					{ routeName = "route", key = "key-2" },
				}
			}

			local newState = StateUtils.replaceAndPrune(initialState, "key-1", {
				routeName = "newRoute", key = "key-3"
			})

			jestExpect(newState.index).toEqual(1)
			jestExpect(#newState.routes).toEqual(1)
			jestExpect(newState.routes[1].routeName).toEqual("newRoute")
			jestExpect(newState.routes[1].key).toEqual("key-3")
		end)
	end)

	describe("StateUtils.replaceAt tests", function()
		it("should assert if state is not a table", function()
			jestExpect(function()
				StateUtils.replaceAt(nil, "key", {}, false)
			end).toThrow()
		end)

		it("should assert if key is not a string", function()
			jestExpect(function()
				StateUtils.replaceAt({}, 0, {}, false)
			end).toThrow()
		end)

		it("should assert if route is not a table", function()
			jestExpect(function()
				StateUtils.replaceAt({}, "key", 0, false)
			end).toThrow()
		end)

		it("should assert if preserveIndex is not a boolean", function()
			jestExpect(function()
				StateUtils.replaceAt({}, "key", {}, 0)
			end).toThrow()
		end)

		it("should replace matching route, not prune, and update index", function()
			local initialState = {
				index = 2,
				routes = {
					{ routeName = "route", key = "key-1" },
					{ routeName = "route", key = "key-2" },
				}
			}

			local newState = StateUtils.replaceAt(initialState, "key-1", {
				routeName = "newRoute", key = "key-3"
			}, false)

			jestExpect(newState.index).toEqual(1)
			jestExpect(#newState.routes).toEqual(2)
			jestExpect(newState.routes[1].routeName).toEqual("newRoute")
			jestExpect(newState.routes[1].key).toEqual("key-3")
		end)

		it("should replace matching route, not prune, and preserve existing index", function()
			local initialState = {
				index = 2,
				routes = {
					{ routeName = "route", key = "key-1" },
					{ routeName = "route", key = "key-2" },
				}
			}

			local newState = StateUtils.replaceAt(initialState, "key-1", {
				routeName = "newRoute", key = "key-3"
			}, true)

			jestExpect(newState.index).toEqual(2)
			jestExpect(#newState.routes).toEqual(2)
			jestExpect(newState.routes[1].routeName).toEqual("newRoute")
			jestExpect(newState.routes[1].key).toEqual("key-3")
		end)
	end)

	describe("StateUtils.replaceAtIndex tests", function()
		it("should assert if state is not a table", function()
			jestExpect(function()
				StateUtils.replaceAtIndex(nil, 0, {})
			end).toThrow()
		end)

		it("should assert if index is not a number", function()
			jestExpect(function()
				StateUtils.replaceAtIndex({}, nil, {})
			end).toThrow()
		end)

		it("should assert if route is not a table", function()
			jestExpect(function()
				StateUtils.replaceAtIndex({}, 5, nil)
			end).toThrow()
		end)

		it("should assert if index does not exist", function()
			jestExpect(function()
				StateUtils.replaceAtIndex({
					index = 0,
					routes = {}
				}, 5, { routeName = "name", key = "key" })
			end).toThrow()
		end)

		it("should return original state if inputs are same", function()
			local testRoute = { routeName = "name", key = "key" }
			local initialState = {
				index = 1,
				routes = { testRoute },
			}

			local newState = StateUtils.replaceAtIndex(initialState, 1, testRoute)
			jestExpect(newState).toBe(initialState)
		end)

		it("should replace route at index if route is not equal", function()
			local initialState = {
				index = 1,
				routes = {
					{ routeName = "name", key = "key" }
				},
			}

			local newState = StateUtils.replaceAtIndex(initialState, 1, {
				routeName = "newName",
				key = "key",
			})

			jestExpect(newState.index).toEqual(1)
			jestExpect(#newState.routes).toEqual(1)
			jestExpect(newState.routes[1].routeName).toEqual("newName")
			jestExpect(newState.routes[1].key).toEqual("key")
		end)

		it("should update index, if new index differs but route does not", function()
			local testRoute = { routeName = "name", key = "key-2" }
			local initialState = {
				index = 1,
				routes = {
					{ routeName = "name", key = "key-1" },
					testRoute,
				}
			}

			local newState = StateUtils.replaceAtIndex(initialState, 2, testRoute)
			jestExpect(newState).never.toBe(initialState)
			jestExpect(newState.index).toEqual(2)
		end)
	end)

	describe("StateUtils.reset tests", function()
		it("should assert if state is not a table", function()
			jestExpect(function()
				StateUtils.reset(nil, {}, 0)
			end).toThrow()
		end)

		it("should assert if routes is not a table", function()
			jestExpect(function()
				StateUtils.reset({}, nil, 0)
			end).toThrow()
		end)

		it("should assert if index is not a number", function()
			jestExpect(function()
				StateUtils.reset({}, {}, "foo")
			end).toThrow()
		end)

		-- the test does not seem to match with the name
		it("should NOT assert if index is nil", function()
			jestExpect(function()
				StateUtils.reset({}, {})
			end).toThrow()
		end)

		it("should return original state if index matches and all routes are same objects", function()
			local route1 = { routeName = "route1", key = "route-1" }
			local route2 = { routeName = "route2", key = "route-2" }

			local initialState = {
				index = 2,
				routes = { route1, route2 },
			}

			local newState = StateUtils.reset(initialState, {
				route1,
				route2,
			}, 2)

			jestExpect(newState).toBe(initialState)
		end)

		it("should update state if index is not specified and old index is not last route", function()
			local route1 = { routeName = "route1", key = "route-1" }
			local route2 = { routeName = "route2", key = "route-2" }

			local initialState = {
				index = 1,
				routes = { route1, route2 },
			}

			local newState = StateUtils.reset(initialState, {
				route1,
				route2,
			})

			jestExpect(newState).never.toBe(initialState)
			jestExpect(newState.index).toEqual(2)
		end)

		it("should update state if index matches but routes differ", function()
			local route1 = { routeName = "route1", key = "route-1" }
			local route2 = { routeName = "route2", key = "route-2" }

			local initialState = {
				index = 1,
				routes = { route1, route2 },
			}

			local newState = StateUtils.reset(initialState, {
				route1,
				{ routeName = "route3", key = "route-3" },
			}, 1)

			jestExpect(newState).never.toBe(initialState)
			jestExpect(#newState.routes).toEqual(2)
			jestExpect(newState.index).toEqual(1)
			jestExpect(newState.routes[2].routeName).toEqual("route3")
			jestExpect(newState.routes[2].key).toEqual("route-3")
		end)
	end)
end
