--!strict

local Fonts = require(script.Parent:WaitForChild("Fonts"))
local QuadToQuad = require(script.Parent:WaitForChild("QuadToQuad"))

type Properties = {[string]: any}

local module = {}

local function getAABB(vertices: {Vector3}): (Vector3, Vector3)
	local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge
	local minX, minY, minZ = math.huge, math.huge, math.huge

	for _, vertex in vertices do
		local x, y, z = vertex.X, vertex.Y, vertex.Z
		maxX = math.max(maxX, x)
		maxY = math.max(maxY, y)
		maxZ = math.max(maxZ, z)
		minX = math.min(minX, x)
		minY = math.min(minY, y)
		minZ = math.min(minZ, z)
	end

	local maxV = Vector3.new(maxX, maxY, maxZ)
	local minV = Vector3.new(minX, minY, minZ)

	return maxV, minV
end

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
	local maxV, minV = getAABB(mutatedVertices)

	local primary = Instance.new("Part")
	primary.Name = "Center"
	primary.CFrame = CFrame.fromEulerAnglesXYZ(0, math.pi, 0)
	primary.Size = glyph.size * scale
	primary.Anchored = true
	primary.CanCollide = false
	primary.Transparency = 1
	primary.Parent = model

	local aabb = Instance.new("Part")
	aabb.Name = "AABB"
	aabb.CFrame = CFrame.new((maxV + minV) / 2) * CFrame.fromEulerAnglesXYZ(0, math.pi, 0)
	aabb.Size = maxV - minV
	aabb.Anchored = true
	aabb.CanCollide = false
	aabb.Transparency = 1
	aabb.Parent = model

	model.PrimaryPart = primary
	
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