--!strict

local Fonts = require(script:WaitForChild("Fonts"))
local Renderer = require(script:WaitForChild("Renderer"))

local module = {}

-- Private

local random = Random.new()

local function lerpNumber(a: number, b: number, t: number): number
	return (1 - t) * a + t * b
end

local function getRandomBoundVec3(x, y)
	return Vector3.new(
		lerpNumber(-x, x, random:NextNumber()),
		lerpNumber(-y, y, random:NextNumber())
	)
end

local function getRandomWarpQuad()
	return {
		TopLeft = Vector3.new(0, 0) + getRandomBoundVec3(0.2, 0.2),
		TopRight = Vector3.new(1, 0) + getRandomBoundVec3(0.2, 0.2),
		BottomRight = Vector3.new(1, 1) + getRandomBoundVec3(0.2, 0.2),
		BottomLeft = Vector3.new(0, 1) + getRandomBoundVec3(0.2, 0.2),
	}
end

-- Public

function module.test(msg: string)
	for i = 1, #msg do
		local char = msg:sub(i, i)
		local glyph = Fonts["Roboto-Regular"][char]

		if glyph then
			local quad = getRandomWarpQuad()

			local glyphModel = Renderer.glyph(glyph, 5, quad, {
				Color = BrickColor.random().Color,
				CastShadow = false,
			})

			glyphModel:PivotTo(CFrame.new(-i * 5, 10, 0))
			glyphModel.Parent = workspace
		end
	end
end

return module