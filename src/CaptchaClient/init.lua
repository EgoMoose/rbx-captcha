--!strict

local Request = script:WaitForChild("Request")
local Respond = script:WaitForChild("Respond")

local module = {}

-- Public

module.onRequest = Request.OnClientEvent

function module.respond(unique: string, answer: string): boolean
	return not not Respond:InvokeServer(unique, answer)
end

--

return module