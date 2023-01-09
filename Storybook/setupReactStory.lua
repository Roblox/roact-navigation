local Storybook = script.Parent
local Packages = Storybook.Parent

local ReactRoblox = require(Packages.Dev.ReactRoblox)

local function setupReactStory(target, element)
	local root = ReactRoblox.createRoot(target)

	ReactRoblox.act(function()
		root:render(element)
	end)

	local function cleanup()
		ReactRoblox.act(function()
			root:unmount()
		end)
	end

	return cleanup
end

return setupReactStory
