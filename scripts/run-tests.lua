local ProcessService = game:GetService("ProcessService")

local root = script.Parent.TestBundle
local Packages = root.Packages

local JestRoblox = require(Packages.Dev.JestRoblox)

local RoactNavigation = Packages.RoactNavigation

local requireOverride = require
local cleanupAll = function() end

if _G.__NEW_ROACT__ then
	local requiredModules: { [ModuleScript]: any } = {
		-- mock Roact with RoactCompat
		[Packages.Roact] = require(Packages.Dev.RoactCompat),
	}
	type CleanupFn = () -> any
	local moduleCleanup: { [ModuleScript]: (() -> any)? } = {}

	function cleanupAll(): any
		for script,cleanup in pairs(moduleCleanup) do
			(cleanup :: CleanupFn)()
		end
		moduleCleanup = {}
	end

	function requireOverride(scriptInstance: ModuleScript): any
		-- If already loaded and cached, return cached module. This should behave
		-- similarly to normal `require` behavior
		if requiredModules[scriptInstance] ~= nil then
			return requiredModules[scriptInstance]
		end

		-- Narrowing this type here lets us appease the type checker while still
		-- counting on types for the rest of this file
		local loadmodule: (ModuleScript) -> (any, string, CleanupFn) = debug["loadmodule"]
		local moduleFunction, errorMessage, cleanup = loadmodule(scriptInstance)
		assert(moduleFunction ~= nil, errorMessage)

		getfenv(moduleFunction).require = requireOverride
		local moduleResult = moduleFunction()

		if moduleResult == nil then
			error(string.format(
				"[Module Error]: %s did not return a valid result\n" ..
				"\tModuleScripts must return a non-nil value",
				tostring(scriptInstance)
			))
		end

		-- Load normally into the require cache
		requiredModules[scriptInstance] = moduleResult
		moduleCleanup[scriptInstance] = cleanup

		return moduleResult
	end
end

local result = JestRoblox.TestBootstrap:run(
	{ RoactNavigation },
	JestRoblox.Reporters.TextReporterQuiet,
	{
		extraEnvironment = {
			require = requireOverride,
		},
	}
)

cleanupAll()

if result.failureCount == 0 and #result.errors == 0 then
	ProcessService:ExitAsync(0)
else
	ProcessService:ExitAsync(1)
end
