return function()
	local RoactNavigationModule = script.Parent.Parent
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestRoblox).Globals.expect

	for _, storyModule in ipairs(Packages.RoactNavigationStorybook:GetDescendants()) do
		local storyName = storyModule.Name:match("(.+)%.story$")
		if storyName then
			it(("mounts %s"):format(storyName), function()
				local storyBuilder = require(storyModule)
				local parent = Instance.new("Folder")

				jestExpect(function()
					local cleanUp = storyBuilder(parent)
					cleanUp()
				end).never.toThrow()
			end)
		end
	end
end
