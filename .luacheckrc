stds.roblox = {
	globals = {
		"game"
	},
	read_globals = {
		-- Roblox globals
		"script",

		-- Extra functions
		"tick", "warn", "spawn",
		"wait", "settings", "typeof",

		-- Types
		"Vector2", "Vector3",
		"Color3",
		"UDim", "UDim2",
		"Rect",
		"CFrame",
		"Enum",
		"Instance",
	}
}

stds.testez = {
	read_globals = {
		"describe",
		"it", "itFOCUS", "itSKIP",
		"beforeEach", "afterEach",
		"FOCUS", "SKIP", "HACK_NO_XPCALL",
		"expect",
		"Rhodium",
	}
}

ignore = {
	"212", -- unused arguments
}

std = "lua51+roblox"

max_comment_line_length = false

files["**/*.spec.lua"] = {
	std = "+testez",
}