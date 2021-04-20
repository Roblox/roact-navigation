return function()
	local routersModule = script.Parent.Parent
	local RoactNavigationModule = routersModule.Parent
	local pathUtils = require(routersModule.pathUtils)
	local Packages = RoactNavigationModule.Parent
	local jestExpect = require(Packages.Dev.JestRoblox).Globals.expect
	local urlToPathAndParams = pathUtils.urlToPathAndParams

	it("urlToPathAndParams empty", function()
		local pathAndParam = urlToPathAndParams("foo://")
		local path = pathAndParam.path
		local params = pathAndParam.params
		jestExpect(path).toEqual("")
		jestExpect(params).toEqual({})
	end)

	it("urlToPathAndParams empty params", function()
		local pathAndParam = urlToPathAndParams("foo://foo/bar/b")
		local path = pathAndParam.path
		local params = pathAndParam.params

		jestExpect(path).toEqual("foo/bar/b")
		jestExpect(params).toEqual({})
	end)

	it("urlToPathAndParams trailing slash", function()
		local pathAndParam = urlToPathAndParams("foo://foo/bar/")
		local path = pathAndParam.path
		local params = pathAndParam.params

		jestExpect(path).toEqual("foo/bar")
		jestExpect(params).toEqual({})
	end)

	it("urlToPathAndParams with params", function()
		local pathAndParam = urlToPathAndParams("foo://foo/bar?asdf=1&dude=foo")
		local path = pathAndParam.path
		local params = pathAndParam.params

		jestExpect(path).toEqual("foo/bar")
		jestExpect(params).toEqual({ asdf = "1", dude = "foo" })
	end)

	it("urlToPathAndParams with custom delimeter string", function()
		local pathAndParam = urlToPathAndParams("https://example.com/foo/bar?asdf=1", "https://example.com/")
		local path = pathAndParam.path
		local params = pathAndParam.params

		jestExpect(path).toEqual("foo/bar")
		jestExpect(params).toEqual({ asdf = "1" })
	end)

	it("urlToPathAndParams with custom delimeter RegExp", function()
		local pathAndParam = urlToPathAndParams(
			"https://example.com/foo/bar?asdf=1",
			"https://example.com/"
		)
		local path = pathAndParam.path
		local params = pathAndParam.params

		jestExpect(path).toEqual("foo/bar")
		jestExpect(params).toEqual({ asdf = "1" })
	end)

	it("urlToPathAndParams with duplicate prefix in query parameters", function()
		local pathAndParam = urlToPathAndParams("example://whatever?related=example://something", "example://")
		local path = pathAndParam.path
		local params = pathAndParam.params

		jestExpect(path).toEqual("whatever")
		jestExpect(params).toEqual({ related = "example://something" })
	end)

	it("urlToPathAndParams with array of custom delimiters, should use first match", function()
		local pathAndParam = urlToPathAndParams("https://example.com/foo/bar?asdf=1", {
			"baz",
			"https://example.com/",
			"https://example.com/foo",
		})
		local path = pathAndParam.path
		local params = pathAndParam.params
		jestExpect(path).toEqual("foo/bar")
		jestExpect(params).toEqual({ asdf = "1" })
	end)

	it("urlToPathAndParams with array of custom delimiters where none match, should resort to default delimiter", function()
		local pathAndParam = urlToPathAndParams("foo://foo/bar?asdf=1", {
			"baz",
			"bazzlefraz",
		})
		local path = pathAndParam.path
		local params = pathAndParam.params

		jestExpect(path).toEqual("foo/bar")
		jestExpect(params).toEqual({ asdf = "1" })
	end)
end
