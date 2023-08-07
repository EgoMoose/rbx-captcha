--!strict

local QuadToQuad = require(script.Parent:WaitForChild("QuadToQuad"))

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

-- Public

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

--

return module