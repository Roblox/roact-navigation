local Roact = require(script.Parent.Parent.Parent.Parent.Roact)
local RoactNavigation = require(script.Parent.Parent.Parent.Parent.RoactNavigation)

return function(target)
    local TopBarTitleContainer = RoactNavigation.TopBarTitleContainer
    local title = Roact.createElement(TopBarTitleContainer, {
        headerTitle = "A good title!",
        headerSubtitle = "Important subtitle!",
        headerTitleContainerStyle = {
            Size = UDim2.new(1, 0, 0, 50)
        }
    })

    local rootInstance = Roact.mount(title, target)

    return function()
		Roact.unmount(rootInstance)
	end
end
