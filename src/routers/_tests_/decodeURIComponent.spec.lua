-- upstream: https://github.com/SamVerschueren/decode-uri-component/blob/v0.2.0/test.js
return function()
	local routersModule = script.Parent.Parent
	local RoactNavigationModule = routersModule.Parent
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestRoblox).Globals.expect

	local decodeURIComponent = require(routersModule.decodeURIComponent)

	local tests = {
		["test"] = "test",
		["a+b"] = "a b",
		["a+b+c+d"] = "a b c d",
		["=a"] = "=a",
		["%"] = "%",
		["%25"] = "%",
		["%%25%%"] = "%%%%",
		-- ["st%C3%A5le"] = "ståle",
		-- ["st%C3%A5le%"] = "ståle%",
		-- ["%st%C3%A5le%"] = "%ståle%",
		-- ["%%7Bst%C3%A5le%7D%"] = "%{ståle}%",
		-- ["%ab%C3%A5le%"] = "%abåle%",
		-- ["%C3%A5%able%"] = "å%able%",
		["%7B%ab%7C%de%7D"] = "{%ab|%de}",
		["%7B%ab%%7C%de%%7D"] = "{%ab%|%de%}",
		["%7 B%ab%%7C%de%%7 D"] = "%7 B%ab%|%de%%7 D",
		["%ab"] = "%ab",
		["%ab%ab%ab"] = "%ab%ab%ab",
		["%61+%4d%4D"] = "a MM",
		[utf8.char(0xFEFF) .. "test"] = utf8.char(0xFEFF) .. "test",
		[utf8.char(0xFEFF)] = utf8.char(0xFEFF),
		-- ["%EF%BB%BFtest"] = utf8.char(0xFEFF) .. "test",
		-- ["%EF%BB%BF"] = utf8.char(0xFEFF),
		-- ["%FE%FF"] = utf8.char(0xFFFD) .. utf8.char(0xFFFD),
		-- ["%FF%FE"] = utf8.char(0xFFFD) .. utf8.char(0xFFFD),
		["†"] = "†",
		["%C2"] = utf8.char(0xFFFD),
		["%C2x"] = utf8.char(0xFFFD) .. "x",
		-- ["%C2%B5"] = "µ",
		-- ["%C2%B5%"] = "µ%",
		-- ["%%C2%B5%"] = "%µ%",
	}

	it("type error", function(t)
		jestExpect(function()
			return decodeURIComponent(5)
		end).toThrow("Expected `encodedURI` to be of type `string`, got `number`")
	end)

	for input, expected in pairs(tests) do
		it(("%s -> %s"):format(input, expected), function()
			jestExpect(decodeURIComponent(input)).toEqual(expected)
		end)
	end
end
