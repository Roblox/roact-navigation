local Roact = require(script.Parent.Parent.Parent.Parent.Roact)
local RoactNavigation = require(script.Parent.Parent.Parent.Parent.RoactNavigation)

return function(target)
    local TopBar = RoactNavigation.TopBar
    local scene = {
        descriptor = {
            options = {
                headerTitle = "HOME",
                headerTitleStyle = {
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                },
                headerStyle = {
                    BackgroundColor3 = Color3.fromRGB(41, 41, 41)
                },
                renderHeaderRight = function()
                    return Roact.createElement("Frame", {
                        Size = UDim2.new(0.3, 0, 1, 0),
                        BackgroundTransparency = 1,
                        LayoutOrder = 3,
                    }, {
                        Layout = Roact.createElement("UIListLayout", {
                            SortOrder = Enum.SortOrder.LayoutOrder,
                            FillDirection = Enum.FillDirection.Horizontal,
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                            HorizontalAlignment = Enum.HorizontalAlignment.Right,
                            Padding = UDim.new(0, 4),
                        }),
                        Notification = Roact.createElement("ImageButton", {
                            Image = "rbxasset://textures/ui/LuaChatV2/actions_notificationOn.png",
                            Size = UDim2.new(0, 36, 0, 36),
                            BackgroundTransparency = 1,
                            LayoutOrder = 1,
                            [Roact.Event.MouseButton1Click] = function()
                                print("Opening notitifications...")
                            end
                        }),
                        Search = Roact.createElement("ImageButton", {
                            Image = "rbxasset://textures/ui/LuaChatV2/common_search.png",
                            Size = UDim2.new(0, 36, 0, 36),
                            BackgroundTransparency = 1,
                            LayoutOrder = 2,
                            [Roact.Event.MouseButton1Click] = function()
                                print("Searching...")
                            end
                        }),
                        Spacer = Roact.createElement("Frame", {
                            Size = UDim2.new(0, 8, 1, 0),
                            BackgroundTransparency = 1,
                            LayoutOrder = 3,
                        }),
                    })
                end,
            },
            navigation = {
                goBack = function(key)
                    print(key)
                end,
            },
            key = "another"
        },
        index = 1,
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
