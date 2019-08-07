local Roact = require(script.Parent.Parent.Parent.Parent.Roact)
local RoactNavigation = require(script.Parent.Parent.Parent.Parent.RoactNavigation)

return function(target)
    local TopBarBackButton = RoactNavigation.TopBarBackButton
    local button = Roact.createElement(TopBarBackButton, {
        goBack = function()
            print("Clicked!")
        end,
    })

    local rootInstance = Roact.mount(button, target)

    return function()
		Roact.unmount(rootInstance)
	end
end
