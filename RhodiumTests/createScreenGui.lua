local HttpService = game:GetService("HttpService")

return function(parent)
	local screen = Instance.new("ScreenGui")
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screen.Name = HttpService:GenerateGUID(false)
	screen.Parent = parent
	return screen
end
