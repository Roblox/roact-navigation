-- upstream https://github.com/react-navigation/react-navigation/blob/f10543f9fcc0f347c9d23aeb57616fd0f21cd4e3/packages/core/src/__tests__/getEventManager.test.js
return function()
	local RoactNavigationModule = script.Parent.Parent
	local getEventManager = require(RoactNavigationModule.getEventManager)
	local Events = require(RoactNavigationModule.Events)
	local Packages = RoactNavigationModule.Parent
	local JestGlobals = require(Packages.Dev.JestGlobals)
	local expect = JestGlobals.expect
	local jest = JestGlobals.jest

	local TARGET = "target"

	it("calls listeners to emitted event", function()
		local eventManager = getEventManager(TARGET)
		local callback, callbackFn = jest.fn()
		eventManager.addListener(Events.DidFocus, callbackFn)

		eventManager.emit(Events.DidFocus)

		expect(callback).toHaveBeenCalledTimes(1)
	end)

	it("does not call listeners connected to a different event", function()
		local eventManager = getEventManager(TARGET)
		local callback, callbackFn = jest.fn()
		eventManager.addListener(Events.DidFocus, callbackFn)

		eventManager.emit("didBlur")

		expect(callback).toHaveBeenCalledTimes(0)
	end)

	it("does not call removed listeners", function()
		local eventManager = getEventManager(TARGET)
		local callback, callbackFn = jest.fn()
		local remove = eventManager.addListener(Events.DidFocus, callbackFn).remove

		eventManager.emit(Events.DidFocus)
		expect(callback).toHaveBeenCalledTimes(1)

		remove()

		eventManager.emit(Events.DidFocus)
		expect(callback).toHaveBeenCalledTimes(1)
	end)

	it("calls the listeners with the given payload", function()
		local eventManager = getEventManager(TARGET)
		local callback, callbackFn = jest.fn()
		eventManager.addListener(Events.DidFocus, callbackFn)

		local payload = { foo = 0 }
		eventManager.emit(Events.DidFocus, payload)

		expect(callback).toHaveBeenCalledWith(payload)
	end)
end
