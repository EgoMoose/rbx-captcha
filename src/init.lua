--!strict

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Helpers = script:WaitForChild("Helpers")
local CaptchaClient = script:WaitForChild("CaptchaClient")

local Request = CaptchaClient:WaitForChild("Request")
local Respond = CaptchaClient:WaitForChild("Respond")

local Fonts = require(script:WaitForChild("Fonts"))

local AABB = require(Helpers:WaitForChild("AABB"))
local Render = require(Helpers:WaitForChild("Render"))
local Random = require(Helpers:WaitForChild("Random"))

local Promise = require(script.Parent:WaitForChild("Promise")) :: any

local module = {}

-- Private

local progressing = {}
local responseBind = Instance.new("BindableEvent")

function Respond.OnServerInvoke(player: Player, unique: string, answer: string)
	responseBind:Fire(player, unique, answer)
	local progress = progressing[unique]
	if progress then
		local result = progress:expect()
		progressing[unique] = nil
		return result
	end
	return false
end

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

	local rendered = Instance.new("Model")
	rendered.Name = "Rendered"
	rendered.Parent = captcha

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
			glyphModel.Parent = rendered

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

		dot.Parent = rendered
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

		curve.Parent = rendered
	end

	captcha.PrimaryPart = aabb
	captcha:PivotTo(CFrame.new(0, 0, 0) * CFrame.fromEulerAnglesXYZ(0, 0, Random.number(-1, 1) * math.rad(10)))

	local parts = {}
	for _, child in rendered:GetDescendants() do
		if child:IsA("BasePart") and child.Name ~= "AABB" then
			table.insert(parts, child)
			child.Parent = nil
		end
	end

	rendered:ClearAllChildren()

	for _, part in parts do
		part.Parent = rendered
	end

	return answer, captcha
end

function module.request(player: Player, length: number): boolean
	local unique = HttpService:GenerateGUID()
	local answer, model = module.generate(player, length)

	local progress = Promise.fromEvent(responseBind.Event, function(sender: Player, sentUnique: string, sentAnswer: string)
		return sender == player and sentUnique == unique
	end):andThen(function(sender: Player, sentUnique: string, sentAnswer: string)
		return sentAnswer:lower() == answer:lower():gsub(" ", "")
	end)

	model.Parent = player:WaitForChild("PlayerGui")

	progressing[unique] = progress
	Request:FireClient(player, unique, model)

	local result = progress:expect()
	model:Destroy()
	return result
end

function module.setup(parent: Instance?)
	CaptchaClient.Parent = parent or ReplicatedStorage
end

--

return module