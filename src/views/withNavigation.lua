-- upstream https://github.com/react-navigation/react-navigation/blob/20e2625f351f90fadadbf98890270e43e744225b/packages/core/src/views/withNavigation.js
local views = script.Parent
local root = views.Parent
local Packages = root.Parent
local LuauPolyfill = require(Packages.LuauPolyfill)
local Object = LuauPolyfill.Object
local Roact = require(Packages.Roact)
local NavigationContext = require(views.NavigationContext)
local invariant = require(root.utils.invariant)

local function isComponent(component)
	local valueType = type(component)
	return valueType == "function" or valueType == "table"
end

--[[
	withNavigation() is a convenience function that you can use in your component's
	render function to access the navigation context object. For example:

	local MyComponent = Roact.Component:extend("MyComponent")

	function MyComponent:render()
		local navigation = self.props.navigation
		return Roact.createElement("TextButton", {
			[Roact.Activated] = function()
				navigation.navigate("DetailPage")
			end
		})
	end

	return withNavigation(MyComponent)
]]
return function(component, config)
	assert(isComponent(component), "withNavigation must be called with a Roact component (stateful or functional)")
	config = config or {}

	if config.forwardRef == nil then
		config.forwardRef = true
	end

	return function(props)
		local navigationProp = props.navigation
		return Roact.createElement(NavigationContext.Consumer, {
			render = function(navigationContext)
				local navigation = navigationProp or navigationContext
				invariant(
					navigation,
					"withNavigation and withNavigationFocus can only "
						.. "be used on a view hierarchy of a navigator. The wrapped component is "
						.. "unable to get access to navigation from props or context."
				)
				return Roact.createElement(
					component,
					Object.assign(table.clone(props), {
						navigation = navigation,
						[Roact.Ref] = if config.forwardRef then props[Roact.Ref] else Object.None,
					})
				)
			end,
		})
	end
end
