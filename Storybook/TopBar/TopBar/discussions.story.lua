local Roact = require(script.Parent.Parent.Parent.Parent.Roact)
local RoactNavigation = require(script.Parent.Parent.Parent.Parent.RoactNavigation)
local Cryo = require(script.Parent.Parent.Parent.Parent.Cryo)

return function(target)
    local TopBar = RoactNavigation.TopBar
    local scene = {
        descriptor = {
            options = {
                headerTitle = "Discussions",
                headerTitleStyle = {
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 26,
                },
                headerStyle = {
                    BackgroundColor3 = Color3.fromRGB(41, 41, 41)
                },
                renderHeaderBackButton = function(props)
                    local mergedProps = Cryo.Dictionary.join(props.headerBackButtonStyle, {
                        Image = "rbxasset://textures/ui/LuaChatV2/navigation_pushBack.png",
                        Size = UDim2.new(0, 36, 0, 36),
                        BackgroundTransparency = 1,
                        [Roact.Event.Activated] = props.goBack,
                    })
                    return Roact.createElement("ImageButton", mergedProps)
                end,
            },
            navigation = {
                goBack = function(key)
                    print(key)
                end,
            },
            key = "another"
        },
        index = 2,
    }
	local props = {
		scenes = {
			scene,
		},
		scene = scene,
	}

    local topBar = Roact.createElement(TopBar, props)

    local screen = Roact.createElement("Frame", {
        Size = UDim2.new(0, 400, 0, 1000)
    }, {
        TopBar = topBar
    })

	local rootInstance = Roact.mount(screen, target)

	return function()
		Roact.unmount(rootInstance)
	end
end
