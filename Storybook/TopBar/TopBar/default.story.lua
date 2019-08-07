local Roact = require(script.Parent.Parent.Parent.Parent.Roact)
local Otter = require(script.Parent.Parent.Parent.Parent.Otter)
local RoactNavigation = require(script.Parent.Parent.Parent.Parent.RoactNavigation)

return function(target)
	local TopBar = RoactNavigation.TopBar
	local StackHeaderMode = RoactNavigation.StackHeaderMode

	local props = {
		scenes = {
			{
				descriptor = {
					options = {

					},
					navigation = {
						goBack = function(key)
							print(key)
						end,
					},
					key = "scenekey1"
				},
				index = 1,
			},
			{
				descriptor = {
					options = {
						headerTitle = "Title",
						headerSubtitle = "Subtitle",
					},
					navigation = {
						goBack = function(key)
							print(key)
						end,
					},
					key = "scenekey2"
				},
				index = 2,
			}
		},
		scene = {
			descriptor = {
				options = {
					headerTitle = "Title",
					headerSubtitle = "Subtitle",
				},
				navigation = {
					goBack = function(key)
						print(key)
					end,
				},
				key = "scenekey2"
			},
			index = 2,
		},
		navigationState = {
			index = 2,
		},
		mode = StackHeaderMode.Screen,
		position = Otter.createSingleMotor(0),
	}

	local button = Roact.createElement(TopBar, props)

	local rootInstance = Roact.mount(button, target)

	return function()
		Roact.unmount(rootInstance)
	end
end
