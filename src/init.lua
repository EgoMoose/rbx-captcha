--!strict

local Helpers = script:WaitForChild("Helpers")
local Fonts = require(script:WaitForChild("Fonts"))

local AABB = require(Helpers:WaitForChild("AABB"))
local Render = require(Helpers:WaitForChild("Render"))
local Random = require(Helpers:WaitForChild("Random"))

local module = {}

-- Private

-- Public

function module.generate(player: Player?, length: number): (string, Model)
	local fonts = {
		Fonts.get("Roboto-Regular"),
		--Fonts.get("Bangers-Regular"),
		--Fonts.get("IndieFlower-Regular"),
	}

	local answer = Random.answer(player, length, fonts)
	local captcha = Instance.new("Model")
	captcha.Name = "Captcha"

	local bounds = {}
	for i = 1, #answer do
		local char = answer:sub(i, i)
		local glyph = fonts[Random.integer(1, #fonts)].glyphs[char]

		if glyph then
			local scale = Random.number(5, 8)
			local height = Random.number(-3, 3)
			local rotation = Random.number(-1, 1) * math.rad(30)
			
			local quad = Random.quad(-0.2, 0.2)

			local glyphModel = Render.glyph(glyph, scale, quad, {
				Color = Random.color(0, 190),
				CastShadow = false,
			})

			glyphModel.Name = char
			glyphModel:PivotTo(CFrame.new(-i * 5, height, 0) * CFrame.fromEulerAnglesXYZ(0, 0, rotation))
			glyphModel.Parent = captcha

			local aabb = glyphModel:FindFirstChild("AABB")
			if aabb and aabb:IsA("BasePart") then
				for _, corner in AABB.corners(aabb.CFrame, aabb.Size / 2) do
					table.insert(bounds, corner)
				end
			end
		end
	end

	local maxV, minV = AABB.get(bounds)

	local aabb = Instance.new("Part")
	aabb.Name = "AABB"
	aabb.CFrame = CFrame.new((maxV + minV) / 2)
	aabb.Size = maxV - minV
	aabb.Anchored = true
	aabb.CanCollide = false
	aabb.Transparency = 1
	aabb.Parent = captcha

	for i = 1, Random.integer(20, 30) do
		local color = Random.color(0, 190)
		local radius = Random.number(0.1, 1)
		
		local position = Vector3.new(
			Random.number(minV.X, maxV.X),
			Random.number(minV.Y, maxV.Y),
			0
		)

		local dot = Render.circle(position, radius, {
			Color = color,
			CastShadow = false,
		})

		dot.Parent = captcha
	end

	for i = 1, Random.integer(3, 6) do
		local curvePoints = {}
		for j = 1, 3 do
			curvePoints[j] = Vector3.new(
				Random.number(minV.X, maxV.X),
				Random.number(minV.Y, maxV.Y),
				0
			)
		end
		
		local color = Random.color(0, 190)
		local a, b, c = unpack(curvePoints)
		
		local curve = Render.curve(a, b, c, {
			Color = color,
			CastShadow = false,
		})

		curve.Parent = captcha
	end

	captcha.PrimaryPart = aabb
	captcha:PivotTo(CFrame.new(0, 10, 0) * CFrame.fromEulerAnglesXYZ(0, 0, Random.number(-1, 1) * math.rad(10)))

	return answer, captcha
end

return module