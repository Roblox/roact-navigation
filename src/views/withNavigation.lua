local Roact = require(script.Parent.Parent.Parent.Roact)
local AppNavigationContext = require(script.Parent.AppNavigationContext)

--[[
	withNavigation() is a convenience function that you can use in your component's
	render function to access the navigation context object. For example:

	function MyComponent:render()
		return withNavigation(function(navigation)
			return Roact.createElement("TextButton", {
				[Roact.Activated] = function()
					navigation.navigate("DetailPage")
				end
			})
		end)
	end
]]
return function(renderProp)
	assert(renderProp ~= nil, "withNavigation must be passed a render prop")
	return Roact.createElement(AppNavigationContext.Consumer, {
		render = renderProp
	})
end
