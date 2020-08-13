return function()
	local assertDeepEqual = require(script.Parent.assertDeepEqual)

	it("should fail with a message when args are not equal", function()
		expect(function()
			assertDeepEqual(1, 2)
		end).to.throw("Values were not deep-equal.\nfirst ~= second")

		expect(function()
			assertDeepEqual({
				foo = 1,
			}, {
				foo = 2,
			})
		end).to.throw("Values were not deep-equal.\nfirst[foo] ~= second[foo]")
	end)

	it("should succeed when comparing non-table equal values", function()
		expect(function()
			assertDeepEqual(1, 1)
		end).never.to.throw()
		expect(function()
			assertDeepEqual("hello", "hello")
		end).never.to.throw()
		expect(function()
			assertDeepEqual(nil, nil)
		end).never.to.throw()

		local someFunction = function() end
		local theSameFunction = someFunction

		expect(function()
			assertDeepEqual(someFunction, theSameFunction)
		end).never.to.throw()

	end)

	it("should succeed when comparing different table identities with same structure", function()
		expect(function()
			assertDeepEqual({
				foo = "bar",
			}, {
				foo = "bar",
			})
		end).never.to.throw()
	end)
end
