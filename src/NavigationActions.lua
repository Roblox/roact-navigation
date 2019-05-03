local NavigationSymbol = require(script.Parent.NavigationSymbol)

local BACK_TOKEN = NavigationSymbol("BACK")
local INIT_TOKEN = NavigationSymbol("INIT")
local NAVIGATE_TOKEN = NavigationSymbol("NAVIGATE")
local SET_PARAMS_TOKEN = NavigationSymbol("SET_PARAMS")
local COMPLETE_TRANSITION_TOKEN = NavigationSymbol("COMPLETE_TRANSITION")

--[[
	NavigationActions provides shared constants and methods to construct
	actions that are dispatched to routers to cause a change in the route.
]]
local NavigationActions = {
	Back = BACK_TOKEN,
	Init = INIT_TOKEN,
	Navigate = NAVIGATE_TOKEN,
	SetParams = SET_PARAMS_TOKEN,
	CompleteTransition = COMPLETE_TRANSITION_TOKEN,
}

NavigationActions.__index = NavigationActions

-- Navigate back in the history (temporally).
function NavigationActions.back(payload)
	local data = payload or {}
	return {
		type = BACK_TOKEN,
		key = data.key,
		immediate = data.immediate,
	}
end

-- Initialize the navigation history if not already defined.
function NavigationActions.init(payload)
	local data = payload or {}
	return {
		type = INIT_TOKEN,
		params = data.params,
	}
end

-- Navigate to an existing or new route.
function NavigationActions.navigate(payload)
	return {
		type = NAVIGATE_TOKEN,
		routeName = payload.routeName,
		params = payload.params,
		action = payload.action,
		key = payload.key,
	}
end

-- Swap out the params for an existing route, matched by the given key.
function NavigationActions.setParams(payload)
	return {
		type = SET_PARAMS_TOKEN,
		key = payload.key,
		params = payload.params,
	}
end

-- For internal use. Triggers completion of a transition animation, if needed by the router.
-- This would be sent on e.g. didMount of the new page, so the router knows that the new screen
-- is ready to be displayed before it animates it in place.
function NavigationActions.completeTransition(payload)
	return {
		type = COMPLETE_TRANSITION_TOKEN,
		key = payload.key,
		toChildKey = payload.toChildKey,
	}
end

return NavigationActions
