return function()
	local Events = require(script.Parent.Parent.Events)
	local getChildEventSubscriber = require(script.Parent.Parent.getChildEventSubscriber)

	local function dummyAddListener() end

	local function makeListenerBundle()
		local testUpstreamListenerMap = {}
		local function testAddUpstreamListener(eventType, callback)
			testUpstreamListenerMap[eventType] = callback

			return {
				remove = function()
					testUpstreamListenerMap[eventType] = nil
				end
			}
		end

		return {
			listenerMap = testUpstreamListenerMap,
			addListener = testAddUpstreamListener,
		}
	end

	local SIMPLE_TEST_KEY = "Foo"

	local SIMPLE_TEST_STATE = {
		state = {
			routes = {
				{ key = SIMPLE_TEST_KEY }
			},
			index = 1,
		},
		lastState = {
			routes = {
				{ key = SIMPLE_TEST_KEY }
			},
			index = 1,
		},
		action = {
			type = "SomeAction"
		},
	}

	it("should return a table with correct members", function()
		local childSubscriber = getChildEventSubscriber(dummyAddListener, SIMPLE_TEST_KEY)

		expect(type(childSubscriber.addListener)).to.equal("function")
		expect(type(childSubscriber.emit)).to.equal("function")
	end)

	describe("addListener tests", function()
		it("should throw on invalid eventType", function()
			local childSubscriber = getChildEventSubscriber(dummyAddListener, SIMPLE_TEST_KEY)

			expect(function()
				childSubscriber.addListener("BadSymbol", function() end)
			end).to.throw()
		end)

		it("should throw on invalid eventHandler", function()
			local childSubscriber = getChildEventSubscriber(dummyAddListener, SIMPLE_TEST_KEY)

			expect(function()
				childSubscriber.addListener(Events.Action, 5)
			end).to.throw()
		end)

		it("should remove the listener", function()
			local childSubscriber = getChildEventSubscriber(dummyAddListener, SIMPLE_TEST_KEY)
			local eventHappened = false
			local connection = childSubscriber.addListener(Events.Refocus, function()
				eventHappened = true
			end)
			connection.remove()

			childSubscriber.emit(Events.Refocus)
			expect(eventHappened).to.equal(false)
		end)
	end)

	describe("emit tests", function()
		it("should throw when trying to emit any event besides Refocus", function()
			local childSubscriber = getChildEventSubscriber(dummyAddListener, SIMPLE_TEST_KEY)

			expect(function()
				childSubscriber.emit(Events.WillFocus)
			end).to.throw()

			expect(function()
				childSubscriber.emit(Events.DidFocus)
			end).to.throw()

			expect(function()
				childSubscriber.emit(Events.WillBlur)
			end).to.throw()

			expect(function()
				childSubscriber.emit(Events.DidBlur)
			end).to.throw()

			expect(function()
				childSubscriber.emit(Events.Action)
			end).to.throw()
		end)

		it("should throw when payload is not a table", function()
			local childSubscriber = getChildEventSubscriber(dummyAddListener, SIMPLE_TEST_KEY)

			expect(function()
				childSubscriber.emit(Events.Refocus, 5)
			end).to.throw()
		end)

		it("should allow external caller to emit a refocus event with valid payload", function()
			local childSubscriber = getChildEventSubscriber(dummyAddListener, SIMPLE_TEST_KEY)

			local testPayload = { a = 1 }
			local outputPayload = nil

			childSubscriber.addListener(Events.Refocus, function(payload)
				outputPayload = payload
			end)

			childSubscriber.emit(Events.Refocus, testPayload)
			expect(outputPayload.a).to.equal(1)
			expect(outputPayload.type).to.equal(Events.Refocus)
		end)

		it("should allow external caller to emit a refocus event with nil payload", function()
			local childSubscriber = getChildEventSubscriber(dummyAddListener, SIMPLE_TEST_KEY)

			local outputPayload = nil

			childSubscriber.addListener(Events.Refocus, function(payload)
				outputPayload = payload
			end)

			childSubscriber.emit(Events.Refocus)
			expect(outputPayload.type).to.equal(Events.Refocus)
		end)
	end)

	describe("upstream event handling tests", function()
		it("should register subscriptions for supported event types", function()
			local testUpstreamListenerMap = {}
			local function testAddUpstreamListener(eventType, callback)
				expect(testUpstreamListenerMap[eventType]).to.equal(nil)
				testUpstreamListenerMap[eventType] = true

				return {
					remove = function() end
				}
			end

			getChildEventSubscriber(testAddUpstreamListener, SIMPLE_TEST_KEY)

			expect(testUpstreamListenerMap[Events.Action]).to.equal(true)
			expect(testUpstreamListenerMap[Events.WillFocus]).to.equal(true)
			expect(testUpstreamListenerMap[Events.DidFocus]).to.equal(true)
			expect(testUpstreamListenerMap[Events.WillBlur]).to.equal(true)
			expect(testUpstreamListenerMap[Events.DidBlur]).to.equal(true)
			expect(testUpstreamListenerMap[Events.Refocus]).to.equal(true)
		end)

		it("should disconnect subscriptions on DidBlur when there is no new route", function()
			local testUpstreamListenerMap = {}
			local function testAddUpstreamListener(eventType, callback)
				testUpstreamListenerMap[eventType] = callback

				return {
					remove = function()
						testUpstreamListenerMap[eventType] = false
					end
				}
			end

			local childSubscriber = getChildEventSubscriber(
				testAddUpstreamListener, SIMPLE_TEST_KEY, "Blurred")

			childSubscriber.addListener(Events.Action, function() end)

			testUpstreamListenerMap[Events.DidBlur]({
				state = {},
				action = {
					type = "SomeAction"
				}
			})

			expect(testUpstreamListenerMap[Events.Action]).to.equal(false)
			expect(testUpstreamListenerMap[Events.WillFocus]).to.equal(false)
			expect(testUpstreamListenerMap[Events.DidFocus]).to.equal(false)
			expect(testUpstreamListenerMap[Events.WillBlur]).to.equal(false)
			expect(testUpstreamListenerMap[Events.DidBlur]).to.equal(false)
			expect(testUpstreamListenerMap[Events.Refocus]).to.equal(false)
		end)

		it("should NOT disconnect subscriptions on DidBlur when there is a new route", function()
			local testUpstreamListenerMap = {}
			local function testAddUpstreamListener(eventType, callback)
				testUpstreamListenerMap[eventType] = callback

				return {
					remove = function()
						testUpstreamListenerMap[eventType] = false
					end
				}
			end

			local childSubscriber = getChildEventSubscriber(testAddUpstreamListener, SIMPLE_TEST_KEY, "Blurred")

			childSubscriber.addListener(Events.Action, function() end)

			testUpstreamListenerMap[Events.DidBlur](SIMPLE_TEST_STATE)

			expect(testUpstreamListenerMap[Events.Action]).to.never.equal(false)
			expect(testUpstreamListenerMap[Events.WillFocus]).to.never.equal(false)
			expect(testUpstreamListenerMap[Events.DidFocus]).to.never.equal(false)
			expect(testUpstreamListenerMap[Events.WillBlur]).to.never.equal(false)
			expect(testUpstreamListenerMap[Events.DidBlur]).to.never.equal(false)
			expect(testUpstreamListenerMap[Events.Refocus]).to.never.equal(false)
		end)

		it("should propagate refocus event from upstream", function()
			local bundle = makeListenerBundle()

			local outputPayload = nil
			local childSubscriber = getChildEventSubscriber(bundle.addListener, SIMPLE_TEST_KEY)
			childSubscriber.addListener(Events.Refocus, function(payload)
				outputPayload = payload
			end)

			bundle.listenerMap[Events.Refocus]({ a = 1 })

			expect(outputPayload.a).to.equal(1)
			expect(outputPayload.type).to.equal(Events.Refocus)
		end)

		it("should emit WillFocus on WillFocus event when previously blurred and child is current index", function()
			local bundle = makeListenerBundle()
			local childSubscriber = getChildEventSubscriber(bundle.addListener, SIMPLE_TEST_KEY)

			local willFocusPayload = nil
			childSubscriber.addListener(Events.WillFocus, function(payload)
				willFocusPayload = payload
			end)

			bundle.listenerMap[Events.WillFocus](SIMPLE_TEST_STATE)

			-- Detailed analysis of generated payload. Further tests will just check that functor was called.
			expect(willFocusPayload).to.never.equal(nil)
			expect(willFocusPayload.state).to.never.equal(nil)
			expect(willFocusPayload.lastState).to.never.equal(nil)
			expect(willFocusPayload.action.type).to.equal("SomeAction")
			expect(willFocusPayload.type).to.equal(Events.WillFocus)
		end)

		it("should emit WillFocus AND DidFocus on Action event when previously blurred and child is current index", function()
			local bundle = makeListenerBundle()
			local childSubscriber = getChildEventSubscriber(bundle.addListener, SIMPLE_TEST_KEY)

			local willFocusCalled = false
			childSubscriber.addListener(Events.WillFocus, function()
				willFocusCalled = true
			end)

			local didFocusCalled = false
			childSubscriber.addListener(Events.DidFocus, function()
				didFocusCalled = true
			end)

			bundle.listenerMap[Events.Action](SIMPLE_TEST_STATE)
			expect(willFocusCalled).to.equal(true)
			expect(didFocusCalled).to.equal(true)
		end)

		it(
			"should NOT emit WillFocus or DidFocus on Action event when previously blurred and child is NOT current index",
			function()
				local bundle = makeListenerBundle()
				local childSubscriber = getChildEventSubscriber(bundle.addListener, SIMPLE_TEST_KEY)

				local willFocusCalled = false
				childSubscriber.addListener(Events.WillFocus, function()
					willFocusCalled = true
				end)

				local didFocusCalled = false
				childSubscriber.addListener(Events.DidFocus, function()
					didFocusCalled = true
				end)

				bundle.listenerMap[Events.Action]({
					state = {
						routes = {
							{ key = SIMPLE_TEST_KEY },
							{ key = "NOT_SIMPLE_TEST_KEY" },
						},
						index = 2,
					},
					action = {
						"SomeAction"
					},
				})

				expect(willFocusCalled).to.equal(false)
				expect(didFocusCalled).to.equal(false)
			end
		)

		it("should emit DidFocus on DidFocus event when previous event was WillFocus and child is current index", function()
			local bundle = makeListenerBundle()
			local childSubscriber = getChildEventSubscriber(bundle.addListener, SIMPLE_TEST_KEY, "Focusing")

			local didFocusCalled = false
			childSubscriber.addListener(Events.DidFocus, function()
				didFocusCalled = true
			end)

			bundle.listenerMap[Events.DidFocus](SIMPLE_TEST_STATE)

			expect(didFocusCalled).to.equal(true)
		end)

		it("should emit DidFocus on Action event when previous event was WillFocus and child is current index", function()
			local bundle = makeListenerBundle()
			local childSubscriber = getChildEventSubscriber(bundle.addListener, SIMPLE_TEST_KEY, "Focusing")

			local didFocusCalled = false
			childSubscriber.addListener(Events.DidFocus, function()
				didFocusCalled = true
			end)

			bundle.listenerMap[Events.Action](SIMPLE_TEST_STATE)

			expect(didFocusCalled).to.equal(true)
		end)

		it("should NOT emit DidFocus on DidFocus event when previous event was WillFocus while transitioning", function()
			local bundle = makeListenerBundle()
			local childSubscriber = getChildEventSubscriber(bundle.addListener, SIMPLE_TEST_KEY, "Focusing")

			local didFocusCalled = false
			childSubscriber.addListener(Events.DidFocus, function()
				didFocusCalled = true
			end)

			bundle.listenerMap[Events.DidFocus]({
				state = {
					routes = {
						{ key = SIMPLE_TEST_KEY }
					},
					index = 1,
					isTransitioning = true,
				},
				action = {
					"SomeAction"
				},
			})

			expect(didFocusCalled).to.equal(false)
		end)

		it("should emit WillBlur on WillBlur event when previous event was DidFocus", function()
			local bundle = makeListenerBundle()
			local childSubscriber = getChildEventSubscriber(bundle.addListener, SIMPLE_TEST_KEY, "Focused")

			local willBlurCalled = false
			childSubscriber.addListener(Events.WillBlur, function()
				willBlurCalled = true
			end)

			bundle.listenerMap[Events.WillBlur](SIMPLE_TEST_STATE)

			expect(willBlurCalled).to.equal(true)
		end)

		it("should emit Action on Action event when previous event was DidFocus", function()
			local bundle = makeListenerBundle()
			local childSubscriber = getChildEventSubscriber(bundle.addListener, SIMPLE_TEST_KEY, "Focused")

			local actionCalled = false
			childSubscriber.addListener(Events.Action, function()
				actionCalled = true
			end)

			bundle.listenerMap[Events.Action](SIMPLE_TEST_STATE)

			expect(actionCalled).to.equal(true)
		end)

		it("should emit DidBlur on DidBlur event when previous event was WillBlur", function()
			local bundle = makeListenerBundle()
			local childSubscriber = getChildEventSubscriber(bundle.addListener, SIMPLE_TEST_KEY, "Blurring")

			local didBlurCalled = false
			childSubscriber.addListener(Events.DidBlur, function()
				didBlurCalled = true
			end)

			bundle.listenerMap[Events.DidBlur](SIMPLE_TEST_STATE)

			expect(didBlurCalled).to.equal(true)
		end)

		it("should emit DidBlur on Action event when previous event was WillBlur and we've finished transitioning", function()
			local bundle = makeListenerBundle()
			local childSubscriber = getChildEventSubscriber(bundle.addListener, "Foo", "Blurring")

			local didBlurCalled = false
			childSubscriber.addListener(Events.DidBlur, function()
				didBlurCalled = true
			end)

			bundle.listenerMap[Events.Action]({
				state = {
					routes = {
						{ key = "Foo" }, -- Transitioned away from this route!
						{ key = "Bar" },
					},
					index = 2,
				},
				lastState = {
					routes = {
						{ key = "Foo" },
						{ key = "Bar" },
					},
					index = 1,
				},
				action = {
					type = "SomeAction"
				},
			})

			expect(didBlurCalled).to.equal(true)
		end)

		it("should emit WillFocus on Action event when previois event was WillBlur, while transitioning to child", function()
			local bundle = makeListenerBundle()
			local childSubscriber = getChildEventSubscriber(bundle.addListener, "Bar", "Blurring")

			local willFocusCalled = false
			childSubscriber.addListener(Events.WillFocus, function()
				willFocusCalled = true
			end)

			bundle.listenerMap[Events.Action]({
				state = {
					routes = {
						{ key = "Foo" }, -- Transitioned away from this route!
						{ key = "Bar" },
					},
					index = 2,
					isTransitioning = true,
				},
				lastState = {
					routes = {
						{ key = "Foo" },
						{ key = "Bar" },
					},
					index = 1,
				},
				action = {
					type = "SomeAction"
				},
			})

			expect(willFocusCalled).to.equal(true)
		end)

		it("should disconnect from input events after finalizing blur if removed from nav state", function()
			local bundle = makeListenerBundle()
			local childSubscriber = getChildEventSubscriber(bundle.addListener, "Bar", "Blurring")

			local didBlurCalled = false
			childSubscriber.addListener(Events.DidBlur, function()
				didBlurCalled = true
			end)

			bundle.listenerMap[Events.Action]({
				state = {
					routes = {
						{ key = "Foo" },
					},
					index = 1,
					isTransitioning = false,
				},
				lastState = {
					routes = {
						{ key = "Foo" },
						{ key = "Bar" }, -- Transitioning away from this route.
					},
					index = 1,
					isTransitioning = true,
				},
				action = {
					type = "SomeAction"
				},
			})

			expect(bundle.listenerMap[Events.Action]).to.equal(nil)
			expect(bundle.listenerMap[Events.Refocus]).to.equal(nil)
			expect(didBlurCalled).to.equal(true) -- Event should still be propagated!
		end)
	end)
end
