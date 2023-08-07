--!strict

local Helpers = script:WaitForChild("Helpers")

local Fonts = require(script:WaitForChild("Fonts"))
local Render = require(Helpers:WaitForChild("Render"))
local Random = require(Helpers:WaitForChild("Random"))

local module = {}

function module.test(msg: string)
	for i = 1, #msg do
		local char = msg:sub(i, i)
		local glyph = Fonts["Roboto-Regular"].glyphs[char]

		if glyph then
			local quad = Random.quad(-0.2, 0.2)

			local glyphModel = Render.glyph(glyph, 5, quad, {
				Color = Random.color(0, 190),
				CastShadow = false,
			})

			glyphModel:PivotTo(CFrame.new(-i * 5, 10, 0))
			glyphModel.Parent = workspace
		end
	end
end

return module