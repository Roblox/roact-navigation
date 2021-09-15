-- upstream https://github.com/react-navigation/react-navigation/blob/f10543f9fcc0f347c9d23aeb57616fd0f21cd4e3/packages/core/src/__tests__/getEventManager.test.js
return function()
	local RoactNavigationModule = script.Parent.Parent
	local getEventManager = require(RoactNavigationModule.getEventManager)
	local Events = require(RoactNavigationModule.Events)
	local createSpy = require(RoactNavigationModule.utils.createSpy)
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestGlobals).expect

	local TARGET = "target"

	it("calls listeners to emitted event", function()
		local eventManager = getEventManager(TARGET)
		local callback = createSpy()
		eventManager.addListener(Events.DidFocus, callback.value)

		eventManager.emit(Events.DidFocus)

		jestExpect(callback.callCount).toEqual(1)
	end)

	it("does not call listeners connected to a different event", function()
		local eventManager = getEventManager(TARGET)
		local callback = createSpy()
		eventManager.addListener(Events.DidFocus, callback.value)

		eventManager.emit("didBlur")

		jestExpect(callback.callCount).toEqual(0)
	end)

	it("does not call removed listeners", function()
		local eventManager = getEventManager(TARGET)
		local callback = createSpy()
		local remove = eventManager.addListener(Events.DidFocus, callback.value).remove

		eventManager.emit(Events.DidFocus)
		jestExpect(callback.callCount).toEqual(1)

		remove()

		eventManager.emit(Events.DidFocus)
		jestExpect(callback.callCount).toEqual(1)
	end)

	it("calls the listeners with the given payload", function()
		local eventManager = getEventManager(TARGET)
		local callback = createSpy()
		eventManager.addListener(Events.DidFocus, callback.value)

		local payload = { foo = 0 }
		eventManager.emit(Events.DidFocus, payload)

		callback:assertCalledWithDeepEqual(payload)
	end)
end
