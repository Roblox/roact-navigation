return function()
	local CoreGui = game:GetService("CoreGui")

	local RhodiumTests = script.Parent.Parent
	local Packages = RhodiumTests.Parent.Packages

	local Rhodium = require(Packages.Dev.Rhodium)
	local Element = Rhodium.Element
	local XPath = Rhodium.XPath

	local LuauPolyfill = require(Packages.LuauPolyfill)
	local Array = LuauPolyfill.Array
	local React = require(Packages.React)
	local RoactNavigation = require(Packages.RoactNavigation)
	local ReactRoblox = require(Packages.Dev.ReactRoblox)

	local JestGlobals = require(Packages.Dev.JestGlobals)
	local expect = JestGlobals.expect

	local createScreenGui = require(RhodiumTests.createScreenGui)
	local TrackNavigationEvents = require(Packages.RoactNavigation.utils.TrackNavigationEvents)
	local PageNavigationEvent = require(Packages.RoactNavigation.utils.PageNavigationEvent)

	local pageOneName = "Page One"
	local pageTwoName = "Page Two"

	local willFocusEvent = RoactNavigation.Events.WillFocus
	local didFocusEvent = RoactNavigation.Events.DidFocus
	local willBlurEvent = RoactNavigation.Events.WillBlur
	local didBlurEvent = RoactNavigation.Events.DidBlur

	local function createButtonPage(pageName, clickTargetPageName, trackNavigationEvents)
		return function(props)
			return React.createElement("TextButton", {
				BackgroundColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.Gotham,
				Size = UDim2.new(1, 0, 1, 0),
				Text = pageName,
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 18,
				[React.Event.Activated] = function()
					props.navigation.navigate(clickTargetPageName)
				end,
			}, {
				NavigationEvents = trackNavigationEvents:createNavigationAdapter(pageName),
			})
		end
	end

	local function RhodiumTestNavigation(stackPresentationStyle)
		expect(stackPresentationStyle).toBeDefined()

		local trackNavigationEvents = TrackNavigationEvents.new()

		local transitionCallbackList = {}
		local screen = createScreenGui(CoreGui)

		local navigator = RoactNavigation.createRobloxStackNavigator({
			{ [pageOneName] = createButtonPage(pageOneName, pageTwoName, trackNavigationEvents) },
			{ [pageTwoName] = createButtonPage(pageTwoName, pageOneName, trackNavigationEvents) },
		}, {
			mode = stackPresentationStyle,
			onTransitionStart = function(nextNavigation, prevNavigation)
				table.insert(transitionCallbackList, {
					type = "start",
					nextNavigation = nextNavigation,
					prevNavigation = prevNavigation,
				})
			end,
			onTransitionEnd = function(nextNavigation, prevNavigation)
				table.insert(transitionCallbackList, {
					type = "end",
					nextNavigation = nextNavigation,
					prevNavigation = prevNavigation,
				})
			end,
			onTransitionStep = function(nextNavigation, prevNavigation, value)
				table.insert(transitionCallbackList, {
					type = "step",
					nextNavigation = nextNavigation,
					prevNavigation = prevNavigation,
					value = value,
				})
			end,
		})
		local appContainer = RoactNavigation.createAppContainer(navigator)

		local rootPath = XPath.new(screen):cat(XPath.new("View.TransitionerScenes"))
		local scene1Path = rootPath:cat(XPath.new("1.DynamicContent.*.Scene"))
		local scene2Path = rootPath:cat(XPath.new("2.DynamicContent.*.Scene"))

		local root = ReactRoblox.createRoot(screen)
		ReactRoblox.act(function()
			root:render(React.createElement(appContainer), {
				detached = true,
			})
		end)

		-- wait for expected events to fire
		trackNavigationEvents:waitForNumberEventsMaxWaitTime(2, 1)
		expect(function()
			trackNavigationEvents:expect({
				PageNavigationEvent.new(pageOneName, willFocusEvent),
				PageNavigationEvent.new(pageOneName, didFocusEvent),
			})
		end).never.toThrow()
		-- did events occur in the expected order
		local button1Element = Element.new(scene1Path)
		expect(button1Element:waitForRbxInstance(1)).toEqual(expect.any("Instance"))
		expect(button1Element:getText()).toEqual(pageOneName)

		-- remove previous events
		trackNavigationEvents:resetNavigationEvents()

		-- verify that no transition events have been generated
		expect(#transitionCallbackList).toEqual(0)

		-- go to page two
		button1Element:click()

		-- wait for expected events to fire
		trackNavigationEvents:waitForNumberEventsMaxWaitTime(4, 1)

		-- Did events occur in the expected order? There is no guarantee of order between
		-- willFocus/willBlur or didFocus/didBlur because of Lua table order semantics, but
		-- the "did" events should always land after the "will" events are both done.
		local willEvents = Array.slice(trackNavigationEvents:getNavigationEvents(), 1, 3)
		table.sort(willEvents, function(a, b)
			return tostring(a.event) < tostring(b.event)
		end)
		local firstWillEvent = PageNavigationEvent.new(pageOneName, willBlurEvent)
		expect(willEvents[1]:equalTo(firstWillEvent)).toEqual(true)
		local secondWillEvent = PageNavigationEvent.new(pageTwoName, willFocusEvent)
		expect(willEvents[2]:equalTo(secondWillEvent)).toEqual(true)

		local didEvents = Array.slice(trackNavigationEvents:getNavigationEvents(), 3, 5)
		table.sort(didEvents, function(a, b)
			return tostring(a.event) < tostring(b.event)
		end)
		local firstDidEvent = PageNavigationEvent.new(pageOneName, didBlurEvent)
		expect(didEvents[1]:equalTo(firstDidEvent)).toEqual(true)
		local secondDidEvent = PageNavigationEvent.new(pageTwoName, didFocusEvent)
		expect(didEvents[2]:equalTo(secondDidEvent)).toEqual(true)

		-- Wait for new page to mount
		local scene2ButtonElement = Element.new(scene2Path)
		expect(scene2ButtonElement:waitForRbxInstance(1)).toBeDefined()
		expect(scene2ButtonElement:getText()).toEqual(pageTwoName)

		-- verify that transition callbacks fired in reasonable sequence
		expect(#transitionCallbackList).toBeGreaterThan(3)

		local firstEntry = transitionCallbackList[1]
		expect(firstEntry).toEqual(expect.objectContaining({
			type = "start",
			nextNavigation = expect.any("table"),
			prevNavigation = expect.any("table"),
		}))

		local lastEntry = transitionCallbackList[#transitionCallbackList]
		expect(lastEntry).toEqual(expect.objectContaining({
			type = "end",
			nextNavigation = expect.any("table"),
			prevNavigation = expect.any("table"),
		}))

		expect(lastEntry.nextNavigation).toBe(firstEntry.nextNavigation)

		for i = 2, #transitionCallbackList - 1, 1 do
			local entry = transitionCallbackList[i]
			expect(entry).toEqual(expect.objectContaining({
				type = "step",
				nextNavigation = firstEntry.nextNavigation,
				prevNavigation = firstEntry.prevNavigation,
			}))
			local previousEntry = transitionCallbackList[i - 1]
			if previousEntry.type == "step" then
				expect(entry.value).toBeGreaterThanOrEqual(previousEntry.value)
			end
		end

		ReactRoblox.act(function()
			root:unmount()
		end)
	end

	for _, stackPresentationStyle in pairs(RoactNavigation.StackPresentationStyle) do
		describe(("Mode: %s - navigation events"):format(tostring(stackPresentationStyle)), function()
			it("should appear in predetermined order", function()
				RhodiumTestNavigation(stackPresentationStyle)
			end)
		end)
	end
end
