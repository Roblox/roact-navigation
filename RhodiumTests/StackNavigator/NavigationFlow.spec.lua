return function()
	local CoreGui = game.CoreGui
	local Element = require(game.CoreGui.RobloxGui.Modules.Rhodium.Element)
	local XPath = require(game.CoreGui.RobloxGui.Modules.Rhodium.XPath)

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

		local appContainer = Roact.createElement("ScreenGui", nil, {
				AppContainer = Roact.createElement(RoactNavigation.createAppContainer(
					RoactNavigation.createStackNavigator({
						routes = {
							[pageOneName] = createButtonPage(pageOneName, pageTwoName, trackNavigationEvents),
							[pageTwoName] = createButtonPage(pageTwoName, pageOneName, trackNavigationEvents),
						},
						initialRouteName = pageOneName,
						mode = stackPresentationStyle,
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

		-- go to page two
		button1Element:click()

		-- wait for expected events to fire
		trackNavigationEvents:waitForNumberEventsMaxWaitTime(4, 1)
		-- did events occur in the expected order
		expect(trackNavigationEvents:equalTo({
			PageNavigationEvent.new(pageOneName, willBlurEvent),
			PageNavigationEvent.new(pageTwoName, willFocusEvent),
			PageNavigationEvent.new(pageOneName, didBlurEvent),
			PageNavigationEvent.new(pageTwoName, didFocusEvent),
		})).to.be.equal(true)

		local scene2ButtonElement = Element.new(scene2Path)
		expect(scene2ButtonElement:waitForRbxInstance(1)).to.be.ok()
		expect(scene2ButtonElement:getText()).to.equal(pageTwoName)
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

