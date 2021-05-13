local LinkingProtocol = {}
local LinkingProtocolMetatable = { __index = LinkingProtocol }

function LinkingProtocol:listenForLuaURLs(callback, sticky)
	self.callback = callback
	self.sticky = sticky
end

function LinkingProtocol:getLastLuaURL()
	return self.lastUrl
end

function LinkingProtocol:stopListeningForLuaURLs()
	self.callback = nil
end

local function createLinkingProtocolMock(lastUrl)
	local linkingProtocolMock = {
		lastUrl = lastUrl or "",
	}

	return setmetatable(linkingProtocolMock, LinkingProtocolMetatable)
end

return createLinkingProtocolMock
