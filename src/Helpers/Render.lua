--!strict

local Fonts = require(script.Parent.Parent:WaitForChild("Fonts"))

local AABB = require(script.Parent:WaitForChild("AABB"))
local QuadToQuad = require(script.Parent:WaitForChild("QuadToQuad"))

type Properties = {[string]: any}

local module = {}

-- Public

function module.circle(position: Vector3, radius: number, properties: Properties): BasePart
	local cylinder = Instance.new("Part")
	cylinder.Anchored = true
	cylinder.CanCollide = false
	cylinder.Shape = Enum.PartType.Cylinder
	cylinder.Size = Vector3.new(0, radius*2, radius*2)
	cylinder.CFrame = CFrame.new(position) * CFrame.fromEulerAnglesXYZ(0, math.pi / 2, 0)

	for property, value in properties do
		(cylinder :: any)[property] = value
	end
	
	return cylinder
end

function module.curve(a: Vector3, b: Vector3, c:Vector3, properties: Properties): Model
	local function bezier(t: number)
		local u = a:Lerp(b, t)
		local v = b:Lerp(c, t)
		return u:Lerp(v, t)
	end
	
	local edgeVertices = {}
	for i = 0, 1, 0.1 do
		local pi = bezier(i)
		local pj = bezier(i + 0.1)
		
		local right = (pi - pj):Cross(Vector3.zAxis).Unit
		
		table.insert(edgeVertices, {
			r = pi + right * 0.1,
			l = pi - right * 0.1
		})
	end
	
	local model = Instance.new("Model")
	model.Name = "Curve"
	
	local count = 0
	for i = 1, #edgeVertices - 1 do
		local evi = edgeVertices[i]
		local evj = edgeVertices[i + 1]
		
		count = count + 1
		local triangle1 = module.triangle(evi.l, evi.r, evj.l, properties)
		triangle1.Name = tostring(count)
		triangle1.Parent = model
		
		count = count + 1
		local triangle2 = module.triangle(evj.l, evj.r, evi.r, properties)
		triangle2.Name = tostring(count)
		triangle2.Parent = model
	end
	
	return model
end

function module.triangle(a: Vector3, b: Vector3, c: Vector3, properties: Properties): Model
	local model = Instance.new("Model")
	
	local ab, ac, bc = b - a, c - a, c - b
	local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)

	if abd > acd and abd > bcd then
		c, a = a, c
	elseif acd > bcd and acd > abd then
		a, b = b, a
	end

	ab, ac, bc = b - a, c - a, c - b

	local xVector = ac:Cross(ab).Unit
	local yVector = bc:Cross(xVector).Unit
	local zVector = bc.Unit

	local height = math.abs(ab:Dot(yVector))
	
	local w1 = Instance.new("WedgePart")
	w1.Anchored = true
	w1.CanCollide = false
	w1.Material = Enum.Material.SmoothPlastic
	w1.Size = Vector3.new(0, height, math.abs(ab:Dot(zVector)))
	w1.CFrame = CFrame.fromMatrix((a + b)/2, xVector, yVector, zVector)
	w1.Parent = model
	
	local w2 = Instance.new("WedgePart")
	w2.Anchored = true
	w2.CanCollide = false
	w2.Material = Enum.Material.SmoothPlastic
	w2.Size = Vector3.new(0, height, math.abs(ac:Dot(zVector)))
	w2.CFrame = CFrame.fromMatrix((a + c)/2, -xVector, yVector, -zVector)
	w2.Parent = model
	
	for property, value in properties do
		local w1a = w1 :: any
		local w2a = w2 :: any
		
		w1a[property] = value
		w2a[property] = value
	end

	return model
end

function module.glyph(glyph: Fonts.Glyph, scale: number, transformQuad: QuadToQuad.Quad, properties: Properties): Model
	local transform = QuadToQuad.uniformSquareToQuad(transformQuad)

	local mutatedVertices = {}
	for i, vertex in glyph.vertices do
		local uniform = vertex / glyph.size
		local transformedUniform = transform(Vector3.new(uniform.X + 0.5, 1 - (uniform.Y + 0.5), 0))
		local transformed = Vector3.new(transformedUniform.X - 0.5, 0.5 - transformedUniform.Y, 0) * glyph.size
		mutatedVertices[i] = transformed * scale
	end

	local model = Instance.new("Model")
	local maxV, minV = AABB.get(mutatedVertices)

	local aabb = Instance.new("Part")
	aabb.Name = "AABB"
	aabb.CFrame = CFrame.new((maxV + minV) / 2) * CFrame.fromEulerAnglesXYZ(0, math.pi, 0)
	aabb.Size = maxV - minV
	aabb.Anchored = true
	aabb.CanCollide = false
	aabb.Transparency = 1
	aabb.Parent = model

	model.WorldPivot = CFrame.fromEulerAnglesXYZ(0, math.pi, 0)
	
	local triangles = Instance.new("Model")
	triangles.Name = "Triangles"
	triangles.Parent = model

	for index, face in glyph.faces do
		local i, j, k = unpack(face)
		
		local vi = mutatedVertices[i]
		local vj = mutatedVertices[j]
		local vk = mutatedVertices[k]
		
		local triangle = module.triangle(vi, vj, vk, properties)
		triangle.Name = tostring(index)
		triangle.Parent = triangles
	end

	return model
end

return module