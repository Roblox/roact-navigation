return function()
	local CoreGui = game.CoreGui
	local Element = require(game.CoreGui.RobloxGui.Modules.Rhodium.Element)
	local XPath = require(game.CoreGui.RobloxGui.Modules.Rhodium.XPath)

	local Cryo = require(script.Parent.Parent.Parent.Cryo)
	local Roact = require(script.Parent.Parent.Parent.Roact)
	local RoactNavigation = require(script.Parent.Parent.Parent.RoactNavigation)

	local TrackNavigationEvents = require(script.Parent.Parent.Parent.RoactNavigation.utils.TrackNavigationEvents)
	local PageNavigationEvent = require(script.Parent.Parent.Parent.RoactNavigation.utils.PageNavigationEvent)

	local pageOneName = "Page One"
	local pageTwoName = "Page Two"

	local willFocusEvent = RoactNavigation.Events.WillFocus
	local didFocusEvent = RoactNavigation.Events.DidFocus
	local willBlurEvent = RoactNavigation.Events.WillBlur
	local didBlurEvent = RoactNavigation.Events.DidBlur

	local function createButtonPage(pageName, clickTargetPageName, trackNavigationEvents)
		return function(props)
			return trackNavigationEvents:createNavigationAdapter(pageName, {
				Roact.createElement("TextButton", {
					BackgroundColor3 = Color3.new(1, 1, 1),
					Font = Enum.Font.Gotham,
					Size = UDim2.new(1, 0, 1, 0),
					Text = pageName,
					TextColor3 = Color3.new(0, 0, 0),
					TextSize = 18,
					[Roact.Event.Activated] = function()
						props.navigation.navigate(clickTargetPageName)
					end,
				})
			})
		end
	end

	local function RhodiumTestNavigation(stackPresentationStyle)
		expect(stackPresentationStyle).to.be.ok()

		local trackNavigationEvents = TrackNavigationEvents.new()

		local transitionCallbackList = {}

		local appContainer = Roact.createElement("ScreenGui", nil, {
				AppContainer = Roact.createElement(RoactNavigation.createAppContainer(
					RoactNavigation.createStackNavigator({
						routes = {
							[pageOneName] = createButtonPage(pageOneName, pageTwoName, trackNavigationEvents),
							[pageTwoName] = createButtonPage(pageTwoName, pageOneName, trackNavigationEvents),
						},
						initialRouteName = pageOneName,
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
				))
			})

		local rootPath = XPath.new("game.CoreGui.RootContainer.AppContainer.TransitionerScenes")
		local scene1Path = rootPath:cat(XPath.new("1.DynamicContent.*.Content.1"))
		local scene2Path = rootPath:cat(XPath.new("2.DynamicContent.*.Content.1"))

		local rootInstance = Roact.mount(appContainer, CoreGui, "RootContainer")

		-- wait for expected events to fire
		trackNavigationEvents:waitForNumberEventsMaxWaitTime(2, 1)
		expect(trackNavigationEvents:equalTo({
			PageNavigationEvent.new(pageOneName, willFocusEvent),
			PageNavigationEvent.new(pageOneName, didFocusEvent),
		})).to.be.equal(true)
		-- did events occur in the expected order
		local button1Element = Element.new(scene1Path)
		expect(button1Element:waitForRbxInstance(1)).to.be.ok()
		expect(button1Element:getText()).to.equal(pageOneName)

		-- remove previous events
		trackNavigationEvents:resetNavigationEvents()

		-- verify that no transition events have been generated
		expect(#transitionCallbackList).to.equal(0)

		-- go to page two
		button1Element:click()

		-- wait for expected events to fire
		trackNavigationEvents:waitForNumberEventsMaxWaitTime(4, 1)

		-- Did events occur in the expected order? There is no guarantee of order between
		-- willFocus/willBlur or didFocus/didBlur because of Lua table order semantics, but
		-- the "did" events should always land after the "will" events are both done.
		local willEvents = Cryo.List.removeRange(trackNavigationEvents:getNavigationEvents(), 3, 4)
		willEvents = Cryo.List.sort(willEvents, function(a, b)
			return tostring(a.event) < tostring(b.event)
		end)
		expect(willEvents[1]:equalTo(PageNavigationEvent.new(pageOneName, willBlurEvent))).to.equal(true)
		expect(willEvents[2]:equalTo(PageNavigationEvent.new(pageTwoName, willFocusEvent))).to.equal(true)

		local didEvents = Cryo.List.removeRange(trackNavigationEvents:getNavigationEvents(), 1, 2)
		didEvents = Cryo.List.sort(didEvents, function(a, b)
			return tostring(a.event) < tostring(b.event)
		end)
		expect(didEvents[1]:equalTo(PageNavigationEvent.new(pageOneName, didBlurEvent))).to.equal(true)
		expect(didEvents[2]:equalTo(PageNavigationEvent.new(pageTwoName, didFocusEvent))).to.equal(true)

		-- Wait for new page to mount
		local scene2ButtonElement = Element.new(scene2Path)
		expect(scene2ButtonElement:waitForRbxInstance(1)).to.be.ok()
		expect(scene2ButtonElement:getText()).to.equal(pageTwoName)

		-- verify that transition callbacks fired in reasonable sequence
		expect(#transitionCallbackList > 3).to.equal(true)

		local firstEntry = transitionCallbackList[1]
		expect(firstEntry.type).to.equal("start")
		expect(firstEntry.nextNavigation).to.never.equal(nil)
		expect(firstEntry.prevNavigation).to.never.equal(nil)

		local lastEntry = transitionCallbackList[#transitionCallbackList]
		expect(lastEntry.type).to.equal("end")
		expect(lastEntry.nextNavigation).to.never.equal(nil)
		expect(lastEntry.prevNavigation).to.never.equal(nil)

		expect(lastEntry.nextNavigation).to.equal(firstEntry.nextNavigation)

		for i=3, #transitionCallbackList-1, 1 do
			expect(transitionCallbackList[i].value > transitionCallbackList[i-1].value).to.equal(true)
			expect(transitionCallbackList[i].nextNavigation).to.equal(firstEntry.nextNavigation)
			expect(transitionCallbackList[i].prevNavigation).to.equal(firstEntry.prevNavigation)
		end

		Roact.unmount(rootInstance)
	end

	for _, stackPresentationStyle in pairs(RoactNavigation.StackPresentationStyle) do
		describe(string.format("Mode: %s - navigation events", tostring(stackPresentationStyle)),
			function()
				it("should appear in predetermined order",
					function()
						RhodiumTestNavigation(stackPresentationStyle)
					end)
			end
		)
	end

end

