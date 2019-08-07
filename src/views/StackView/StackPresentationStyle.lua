local NavigationSymbol = require(script.Parent.Parent.Parent.NavigationSymbol)

local DEFAULT_SYMBOL = NavigationSymbol("DEFAULT")
local MODAL_SYMBOL = NavigationSymbol("MODAL")
local OVERLAY_SYMBOL = NavigationSymbol("OVERLAY")

--[[
	StackPresentationStyle is used with stack navigators/views to determine
	the behavior of a given view when it is pushed/popped from the stack, as
	well as the visual effects applied while the view is on screen.
]]
return {
	--[[
		The Default presentation style follows the expected behavior of the host
		operating system. For example, on iOS, views will slide in and out from
		the right side; on Android, they will pop on and off screen. No special
		visual effects are applied to default views; they fill the entire space
		available and are always opaque.
	]]
	Default = DEFAULT_SYMBOL,

	--[[
		The Modal presentation style causes the screen to animate according to
		modal behaviors for the host operating system. Modals are allowed to
		have transparency and they apply a darkening and blur to the underlying
		content. They are always presented full-screen and will obscure other
		visual elements even if they are declared within a navigator that
		occupies a sub-area of another screen.
	]]
	Modal = MODAL_SYMBOL,

	--[[
		The Overlay presentation style causes the view to be displayed full-screen
		on top of other visual elements much like for modals. The key difference is
		that overlays pop in/out instead of animating in from the bottom, and they
		do not blur the underlying content. This makes them ideal for tool-tips and
		informative pop-ups (e.g. toasts).
	]]
	Overlay = OVERLAY_SYMBOL
}
