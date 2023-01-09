local RhodiumTests = script.Parent
local Packages = RhodiumTests.Parent.Packages

local ReactRoblox = require(Packages.Dev.ReactRoblox)

local function compareParams(paramsA, paramsB)
	local pairCount = 0

	for key, value in paramsA do
		if value ~= paramsB[key] then
			if type(value) == "table" then
				if not compareParams(value, paramsB[key]) then
					return false
				end
			end

			return false
		end

		pairCount = pairCount + 1
	end

	for _ in paramsB do
		if pairCount == 0 then
			return false
		end
		pairCount = pairCount - 1
	end

	return true
end

local DEFAULT_TIMEOUT = 2

local TrackRobloxStackNavigatorRoute = {}
TrackRobloxStackNavigatorRoute.__index = TrackRobloxStackNavigatorRoute

function TrackRobloxStackNavigatorRoute.new(timeout, logRouteEvent)
	local self = {
		timeout = timeout or DEFAULT_TIMEOUT,
		currentRoute = nil,
	}
	self.onTransitionEnd = function(nextNavigation, _prevNavigation)
		local state = nextNavigation.state
		self.currentRoute = state.routes[state.index]

		if logRouteEvent then
			print("Transition ended:", self.currentRoute.routeName)
			local params = self.currentRoute.params

			if params then
				for key, value in params do
					print("    ", key, "=", value)
				end
			end
		end
	end

	setmetatable(self, TrackRobloxStackNavigatorRoute)

	return self
end

function TrackRobloxStackNavigatorRoute:waitForRoute(routeName, params)
	local waitedTime = 0

	while not self:isRoute(routeName, params) do
		if waitedTime > self.timeout then
			error(self:_getTimeoutMessage(routeName, params))
		end
		ReactRoblox.act(function()
			waitedTime = waitedTime + task.wait()
		end)
	end
end

function TrackRobloxStackNavigatorRoute:isRoute(routeName, params)
	if not self.currentRoute then
		return false
	end

	if params then
		return self.currentRoute.routeName == routeName and compareParams(params, self.currentRoute.params or {})
	end

	return self.currentRoute.routeName == routeName
end

function TrackRobloxStackNavigatorRoute:_getTimeoutMessage(expectRouteName, expectedParams)
	local paramsString = ""

	if expectedParams then
		local view = {}
		for key, value in expectedParams do
			table.insert(view, ("%s = %s"):format(key, tostring(value)))
		end
		if #view == 0 then
			paramsString = " {}"
		else
			paramsString = (" { %s }"):format(table.concat(view, ", "))
		end
	end

	return ("Timeout while waiting for route %q%s"):format(expectRouteName, paramsString)
end

return TrackRobloxStackNavigatorRoute
