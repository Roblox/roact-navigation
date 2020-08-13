-- upstream https://github.com/react-navigation/react-navigation/blob/72e8160537954af40f1b070aa91ef45fc02bba69/packages/core/src/__tests__/NavigationStateUtils.test.js

return function()
	local StateUtils = require(script.Parent.Parent.StateUtils)

	local utils = script.Parent.Parent.utils
	local assertDeepEqual = require(utils.assertDeepEqual)

	local routeName = "Anything"

	describe("StateUtils", function()
		it("gets route", function()
			local state = {
				index = 1,
				routes = {
					{
						routeName = routeName,
						key = "a",
					},
				},
			}

			assertDeepEqual(
				StateUtils.get(state, "a"),
				{
					key = "a",
					routeName = routeName,
				}
			)
			expect(StateUtils.get(state, "b")).to.equal(nil)
		end)

		-- WILLFIX(deviation)
		itSKIP("gets route index", function()
			local state = {
				index = 1,
				routes = {
					{ key = "a", routeName = routeName },
					{ key = "b", routeName = routeName },
				},
				isTransitioning = false,
			}

			expect(StateUtils.indexOf(state, "a")).to.equal(1)
			expect(StateUtils.indexOf(state, "b")).to.equal(2)
			expect(StateUtils.indexOf(state, "c")).to.equal(-1)
		end)

		it("has a route", function()
			local state = {
				index = 1,
				routes = {
					{ key = "a", routeName = routeName },
					{ key = "b", routeName = routeName },
				},
				isTransitioning = false,
			}

			expect(StateUtils.has(state, "b")).to.equal(true)
			expect(StateUtils.has(state, "c")).to.equal(false)
		end)

		it("pushes a route", function()
			local state = {
				index = 1,
				routes = {{ key = "a", routeName = routeName }},
				isTransitioning = false,
			}
			local newState = {
				index = 2,
				isTransitioning = false,
				routes = {
					{ key = "a", routeName = routeName },
					{ key = "b", routeName = routeName },
				},
			}

			assertDeepEqual(
				StateUtils.push(state, { key = "b", routeName = routeName }),
				newState
			)
		end)

		-- WILLFIX(deviation)
		itSKIP("does not push duplicated route", function()
			local state = {
				index = 1,
				routes = {{ key = "a", routeName = routeName }},
				isTransitioning = false,
			}

			expect(function()
				StateUtils.push(state, { key = "a", routeName = routeName })
			end).to.throw("should not push route with duplicated key a")
		end)

		it("pops route", function()
			local state = {
				index = 2,
				routes = {
					{ key = "a", routeName = routeName },
					{ key = "b", routeName = routeName },
				},
				isTransitioning = false,
			}
			local newState = {
				index = 1,
				routes = {{ key = "a", routeName = routeName }},
				isTransitioning = false,
			}

			assertDeepEqual(StateUtils.pop(state), newState)
		end)

		-- WILLFIX(deviation)
		itSKIP("does not pop route if not applicable", function()
			local state = {
				index = 1,
				routes = {{ key = "a", routeName = routeName }},
				isTransitioning = false,
			}

			assertDeepEqual(
				StateUtils.pop(state),
				state
			)
		end)

		it("jumps to new index", function()
			local state = {
				index = 1,
				routes = {
					{ key = "a", routeName = routeName },
					{ key = "b", routeName = routeName },
				},
				isTransitioning = false,
			}
			local newState = {
				index = 2,
				routes = {
					{ key = "a", routeName = routeName },
					{ key = "b", routeName = routeName },
				},
				isTransitioning = false,
			}

			assertDeepEqual(
				StateUtils.jumpToIndex(state, 1),
				state
			)
			assertDeepEqual(
				StateUtils.jumpToIndex(state, 2),
				newState
			)
		end)

		-- WILLFIX(deviation)
		itSKIP("throws if jumps to invalid index", function()
			local state = {
				index = 1,
				routes = {
					{ key = "a", routeName = routeName },
					{ key = "b", routeName = routeName },
				},
				isTransitioning = false,
			}

			expect(function()
				StateUtils.jumpToIndex(state, 3)
			end).to.throw("invalid index 3 to jump to")
		end)

		it("jumps to new key", function()
			local state = {
				index = 1,
				routes = {
					{ key = "a", routeName = routeName },
					{ key = "b", routeName = routeName },
				},
				isTransitioning = false,
			}
			local newState = {
				index = 2,
				routes = {
					{ key = "a", routeName = routeName },
					{ key = "b", routeName = routeName },
				},
				isTransitioning = false,
			}

			assertDeepEqual(
				StateUtils.jumpTo(state, "a"),
				state
			)
			assertDeepEqual(
				StateUtils.jumpTo(state, "b"),
				newState
			)
		end)

		itSKIP("throws if jumps to invalid key", function()
			local state = {
				index = 1,
				routes = {
					{ key = "a", routeName = routeName },
					{ key = "b", routeName = routeName },
				},
			  isTransitioning = false,
			}

			expect(function()
				StateUtils.jumpTo(state, "c")
			end).to.throw("invalid index -1 to jump to")
		end)

		it("move backwards", function()
			local state = {
				index = 2,
				routes = {
					{ key = "a", routeName = routeName },
					{ key = "b", routeName = routeName },
				},
				isTransitioning = false,
			}
			local newState = {
				index = 1,
				routes = {
					{ key = "a", routeName = routeName },
					{ key = "b", routeName = routeName },
				},
				isTransitioning = false,
			}

			assertDeepEqual(
				StateUtils.back(state),
				newState
			)
			assertDeepEqual(
				StateUtils.back(newState),
				newState
			)
		end)

		it("move forwards", function()
			local state = {
				index = 1,
				routes = {
					{ key = "a", routeName = routeName },
					{ key = "b", routeName = routeName },
				},
				isTransitioning = false,
			}
			local newState = {
				index = 2,
				routes = {
					{ key = "a", routeName = routeName },
					{ key = "b", routeName = routeName },
				},
				isTransitioning = false,
			}
			assertDeepEqual(
				StateUtils.forward(state),
				newState
			)
			assertDeepEqual(
				StateUtils.forward(newState),
				newState
			)
		end)

		it("Replaces by key", function()
			local state = {
				index = 1,
				routes = {
					{ key = "a", routeName = routeName },
					{ key = "b", routeName = routeName },
				},
				isTransitioning = false,
			}
			local newState = {
				index = 2,
				routes = {
					{ key = "a", routeName = routeName },
					{ key = "c", routeName = routeName },
				},
				isTransitioning = false,
			}

			assertDeepEqual(
				StateUtils.replaceAt(state, "b", { key = "c", routeName = routeName }),
				newState
			)
		end)

		it("Replaces by index", function()
			local state = {
				index = 1,
				routes = {
					{ key = "a", routeName = routeName },
					{ key = "b", routeName = routeName },
				},
				isTransitioning = false,
			}
			local newState = {
				index = 2,
				routes = {
					{ key = "a", routeName = routeName },
					{ key = "c", routeName = routeName },
				},
				isTransitioning = false,
			}

			assertDeepEqual(
				StateUtils.replaceAtIndex(state, 2, { key = "c", routeName = routeName }),
				newState
			)
		end)

		it("Returns the state with updated index if route is unchanged but index changes", function()
			local state = {
				index = 1,
				routes = {
					{ key = "a", routeName = routeName },
					{ key = "b", routeName = routeName },
				},
				isTransitioning = false,
			}

			assertDeepEqual(
				StateUtils.replaceAtIndex(state, 2, state.routes[2]),
				{
					index = 2,
					routes = {
						{ key = "a", routeName = routeName },
						{ key = "b", routeName = routeName },
					},
					isTransitioning = false,
				}
			)
		end)

		-- WILLFIX(deviation)
		itSKIP("Resets routes", function()
			local state = {
				index = 1,
				routes = {
					{ key = "a", routeName = routeName },
					{ key = "b", routeName = routeName },
				},
				isTransitioning = false,
			}
			local newState = {
				index = 2,
				routes = {
					{ key = "x", routeName = routeName },
					{ key = "y", routeName = routeName },
				},
				isTransitioning = false,
			}

			assertDeepEqual(
				StateUtils.reset(state, {
					{ key = "x", routeName = routeName },
					{ key = "y", routeName = routeName },
				}),
				newState
			)
			expect(function()
				StateUtils.reset(state, {})
			end).to.throw("invalid routes to replace")
		end)

		-- WILLFIX(deviation)
		itSKIP("Resets routes with index", function()
			local state = {
				index = 1,
				routes = {
					{ key = "a", routeName = routeName },
					{ key = "b", routeName = routeName },
				},
				isTransitioning = false,
			}
			local newState = {
				index = 1,
				routes = {
					{ key = "x", routeName = routeName },
					{ key = "y", routeName = routeName },
				},
				isTransitioning = false,
			}

			assertDeepEqual(
				StateUtils.reset(state, {
					{ key = "x", routeName = routeName },
					{ key = "y", routeName = routeName },
				}, 1),
				newState
			)
			expect(function()
				StateUtils.reset(state, {
					{ key = "x", routeName = routeName },
					{ key = "y", routeName = routeName },
				}, 100)
			end).to.throw("invalid index 100 to reset")
		end)
	end)
end
