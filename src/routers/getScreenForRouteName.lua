local validate = require(script.Parent.Parent.utils.validate)
local isValidScreenComponent = require(script.Parent.Parent.utils.isValidScreenComponent)

-- Extract a single screen Roact component/navigator from
-- a navigator's config.
return function(routeConfigs, routeName)
	validate(type(routeConfigs) == "table", "routeConfigs must be a table")
	validate(type(routeName) == "string", "routeName must be a string")

	local routeConfig = routeConfigs[routeName]

	if routeConfig == nil then
		local possibleRoutes = {}
		local possibleRouteCount = 0

		for name in pairs(routeConfigs) do
			possibleRouteCount = possibleRouteCount + 1
			possibleRoutes[possibleRouteCount] = ("'%s'"):format(name)
		end

		local message = ("There is no route defined for key %s.\nMust be one of: %s"):format(
			routeName,
			table.concat(possibleRoutes, ",")
		)
		error(message, 2)
	end

	local routeConfigType = type(routeConfig)

	if routeConfigType == "table" then
		if routeConfig.screen ~= nil then
			validate(isValidScreenComponent(routeConfig.screen),
				"screen param for key '%s' must be a valid Roact component.", routeName)
			return routeConfig.screen
		elseif type(routeConfig.getScreen) == "function" then
			local screen = routeConfig.getScreen()
			validate(isValidScreenComponent(screen),
				"The getScreen function defined for route '%s' did not return a valid screen or navigator", routeName)
			return screen
		end
	end

	validate(isValidScreenComponent(routeConfig),
		"Value for key '%s' must be a route config table or a valid Roact component.", routeName)

	return routeConfig
end
