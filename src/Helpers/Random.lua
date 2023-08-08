--!strict

local Fonts = require(script.Parent.Parent:WaitForChild("Fonts"))
local QuadToQuad = require(script.Parent:WaitForChild("QuadToQuad"))

local TextService = game:GetService("TextService")

local module = {}
local random = Random.new()

-- Private

local function lerpNumber(a: number, b: number, t: number): number
	return (1 - t) * a + t * b
end

local function randomArr(n: number, min: number, max: number): {number}
	local arr = {}
	for i = 1, n do
		arr[i] = lerpNumber(min, max, random:NextNumber())
	end
	return arr
end

local function randomAnswer(length: number, fonts: {Fonts.Font}): string
	local arr = {}
	for character, _ in Fonts.getCharacterIntersection(fonts) do
		table.insert(arr, character)
	end

	local result = ""
	for i = 1, length do
		local character = arr[random:NextInteger(1, #arr) + 1] or " "
		result = result .. character
	end

	return result
end

local function filterText(player: Player, text: string): string?
	local filteredTextResult = nil
	local success, _errorMessage = pcall(function()
		filteredTextResult = TextService:FilterStringAsync(text, player.UserId)
	end)

	if success and filteredTextResult then
		local filteredText = filteredTextResult:GetNonChatStringForBroadcastAsync()
		if not filteredText:match("#") then
			return filteredText
		end
	end
	
	return nil
end

-- Public

function module.integer(min: number, max: number): number
	return random:NextInteger(min, max)
end

function module.number(min: number, max: number): number
	return lerpNumber(min, max, random:NextNumber())
end

function module.quad(min: number, max: number): QuadToQuad.Quad
	return {
		TopLeft = Vector3.new(0, 0) + Vector3.new(unpack(randomArr(2, min, max))),
		TopRight = Vector3.new(1, 0) + Vector3.new(unpack(randomArr(2, min, max))),
		BottomRight = Vector3.new(1, 1) + Vector3.new(unpack(randomArr(2, min, max))),
		BottomLeft = Vector3.new(0, 1) + Vector3.new(unpack(randomArr(2, min, max))),
	}
end

function module.color(min: number, max: number): Color3
	local rgb = randomArr(3, min, max)
	return Color3.fromRGB(unpack(rgb))
end

function module.answer(player: Player?, length: number, fonts: {Fonts.Font}): string
	while true do
		local answer = randomAnswer(length, fonts)
		local filtered = if player then filterText(player, answer) else answer

		if filtered then
			return filtered
		end
	end
end

--

return module