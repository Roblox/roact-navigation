-- upstream https://github.com/react-navigation/react-navigation/blob/62da341b672a83786b9c3a80c8a38f929964d7cc/packages/core/src/__tests__/NavigationStateUtils.test.js

return function()
	local RoactNavigationModule = script.Parent.Parent
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestGlobals).expect

	local StateUtils = require(RoactNavigationModule.StateUtils)

	local routeName = "Anything"

	describe("StateUtils", function()
		describe("get", function()
			it("gets route", function()
				local state = {
					index = 1,
					routes = {
						{
							key = "a",
							routeName = routeName,
						},
					},
				}

				jestExpect(StateUtils.get(state, "a")).toEqual({
					key = "a",
					routeName = routeName,
				})
			end)

			it("returns null when getting an unknown route", function()
				local state = {
					index = 1,
					routes = {
						{
							key = "a",
							routeName = routeName,
						},
					},
				}

				jestExpect(StateUtils.get(state, "b")).toBe(nil)
			end)
		end)

		describe("indexOf", function()
			it("gets route index", function()
				local state = {
					index = 1,
					routes = {
						{ key = "a", routeName = routeName },
						{ key = "b", routeName = routeName },
					},
					isTransitioning = false,
				}

				jestExpect(StateUtils.indexOf(state, "a")).toBe(1)
				jestExpect(StateUtils.indexOf(state, "b")).toBe(2)
			end)

			-- deviation(will not fix): it is preferable to return `nil` as it's
			-- more common so there is less chance to surprise the consumer of
			-- that function
			itSKIP("returns -1 when getting an unknown route index", function()
				local state = {
					index = 1,
					routes = {
						{ key = "a", routeName = routeName },
					},
					isTransitioning = false,
				}
				jestExpect(StateUtils.indexOf(state, "b")).toBe(-1)
			end)
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

			jestExpect(StateUtils.has(state, "b")).toBe(true)
			jestExpect(StateUtils.has(state, "c")).toBe(false)
		end)

		describe("push", function()
			it("pushes a route", function()
				local state = {
					index = 1,
					routes = { { key = "a", routeName = routeName } },
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

				jestExpect(StateUtils.push(state, { key = "b", routeName = routeName })).toEqual(newState)
			end)

			it("does not push duplicated route", function()
				local state = {
					index = 1,
					routes = { { key = "a", routeName = routeName } },
					isTransitioning = false,
				}

				jestExpect(function()
					StateUtils.push(state, { key = "a", routeName = routeName })
				end).toThrow("should not push route with duplicated key a")
			end)
		end)

		describe("pop", function()
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
					routes = { { key = "a", routeName = routeName } },
					isTransitioning = false,
				}

				jestExpect(StateUtils.pop(state)).toEqual(newState)
			end)

			it("does not pop route if not applicable with single route config", function()
				local state = {
					index = 1,
					routes = { { key = "a", routeName = routeName } },
					isTransitioning = false,
				}
				jestExpect(StateUtils.pop(state)).toBe(state)
			end)

			it("does not pop route if not applicable with multiple route config", function()
				local state = {
					index = 1,
					routes = {
						{ key = "a", routeName = routeName },
						{ key = "b", routeName = routeName },
					},
					isTransitioning = false,
				}
				jestExpect(StateUtils.pop(state)).toBe(state)
			end)
		end)

		describe("jumpToIndex", function()
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

				jestExpect(StateUtils.jumpToIndex(state, 1)).toBe(state)
				jestExpect(StateUtils.jumpToIndex(state, 2)).toEqual(newState)
			end)

			it("throws if jumps to invalid index", function()
				local state = {
					index = 1,
					routes = {
						{ key = "a", routeName = routeName },
						{ key = "b", routeName = routeName },
					},
					isTransitioning = false,
				}

				jestExpect(function()
					StateUtils.jumpToIndex(state, 3)
				end).toThrow("invalid index 3 to jump to")
			end)
		end)

		describe("jumpTo", function()
			it("jumps to the current key", function()
				local state = {
					index = 1,
					routes = {
						{ key = "a", routeName = routeName },
						{ key = "b", routeName = routeName },
					},
					isTransitioning = false,
				}
				jestExpect(StateUtils.jumpTo(state, "a")).toBe(state)
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

				jestExpect(StateUtils.jumpTo(state, "b")).toEqual(newState)
			end)

			it("throws if jumps to invalid key", function()
				local state = {
					index = 1,
					routes = {
						{ key = "a", routeName = routeName },
						{ key = "b", routeName = routeName },
					},
					isTransitioning = false,
				}

				jestExpect(function()
					StateUtils.jumpTo(state, "c")
				end).toThrow('attempt to jump to unknown key "c"')
			end)
		end)

		describe("back", function()
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

				jestExpect(StateUtils.back(state)).toEqual(newState)
			end)

			it("does not move backwards when the active route is the first", function()
				local state = {
					index = 1,
					routes = {
						{ key = "a", routeName = routeName },
						{ key = "b", routeName = routeName },
					},
					isTransitioning = false,
				}
				jestExpect(StateUtils.back(state)).toBe(state)
			end)
		end)

		describe("forward", function()
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
				jestExpect(StateUtils.forward(state)).toEqual(newState)
			end)

			it("does not move forward when active route is already the top-most", function()
				local state = {
					index = 2,
					routes = {
						{ key = "a", routeName = routeName },
						{ key = "b", routeName = routeName },
					},
					isTransitioning = false,
				}
				jestExpect(StateUtils.forward(state)).toEqual(state)
			end)
		end)

		describe("replace", function()
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

				jestExpect(StateUtils.replaceAt(state, "b", { key = "c", routeName = routeName })).toEqual(newState)
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

				jestExpect(StateUtils.replaceAtIndex(state, 2, { key = "c", routeName = routeName })).toEqual(newState)
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

				jestExpect(StateUtils.replaceAtIndex(state, 2, state.routes[2])).toEqual({
					index = 2,
					routes = {
						{ key = "a", routeName = routeName },
						{ key = "b", routeName = routeName },
					},
					isTransitioning = false,
				})
			end)
		end)

		describe("reset", function()
			it("Resets routes", function()
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

				jestExpect(StateUtils.reset(state, {
					{ key = "x", routeName = routeName },
					{ key = "y", routeName = routeName },
				})).toEqual(newState)
			end)

			it("throws when attempting to set empty state", function()
				local state = {
					index = 1,
					routes = {
						{ key = "a", routeName = routeName },
						{ key = "b", routeName = routeName },
					},
					isTransitioning = false,
				}
				jestExpect(function()
					StateUtils.reset(state, {})
				end).toThrow("invalid routes to replace")
			end)

			it("Resets routes with index", function()
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

				jestExpect(StateUtils.reset(state, {
					{ key = "x", routeName = routeName },
					{ key = "y", routeName = routeName },
				}, 1)).toEqual(newState)
			end)

			it("throws when attempting to set an out of range route index", function()
				local state = {
					index = 1,
					routes = {
						{ key = "a", routeName = routeName },
						{ key = "b", routeName = routeName },
					},
					isTransitioning = false,
				}
				jestExpect(function()
					StateUtils.reset(state, {
						{ key = "x", routeName = routeName },
						{ key = "y", routeName = routeName },
					}, 100)
				end).toThrow("invalid index 100 to reset")
			end)
		end)
	end)
end
