local validate = require(script.Parent.Parent.utils.validate)
local isValidRoactElementType = require(script.Parent.Parent.utils.isValidRoactElementType)

-- Extract a single screen Roact component/navigator from
-- a navigator's config.
return function(routeConfigs, routeName)
	validate(type(routeConfigs) == "table", "routeConfigs must be a table")
	validate(type(routeName) == "string", "routeName must be a string")

	local routeConfig = routeConfigs[routeName]
	validate(type(routeConfig) == "table",
		"routeName '%s' must be a table within routeConfigs", routeName)

	if routeConfig.screen ~= nil then
		return routeConfig.screen
	elseif type(routeConfig.getScreen) == "function" then
		local screen = routeConfig.getScreen()
		validate(isValidRoactElementType(screen),
			"The getScreen function defined for route '%s' did not return a valid screen or navigator", routeName)
		return screen
	else
		return routeConfig
	end
end
