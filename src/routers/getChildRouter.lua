local validate = require(script.Parent.Parent.utils.validate)

return function(router, routeName)
	validate(type(router) == "table", "router must be a table")
	validate(type(routeName) == "string", "routeName must be a string")

	if router.childRouters and router.childRouters[routeName] then
		return router.childRouters[routeName]
	end

	validate(type(router.getComponentForRouteName) == "function",
		"router.getComponentForRouteName must be a function if no child routers are specified")
	return router.getComponentForRouteName(routeName).router
end

