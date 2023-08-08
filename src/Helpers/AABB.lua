--!strict

local module = {}

function module.corners(cframe: CFrame, size2: Vector3): {Vector3}
	local corners = {}
	for i = 0, 7 do
		corners[i + 1] = cframe * (size2 * Vector3.new(
			2 * (math.floor(i / 4) % 2) - 1,
			2 * (math.floor(i / 2) % 2) - 1,
			2 * (i % 2) - 1
		))
	end
	return corners
end

function module.get(vertices: {Vector3}): (Vector3, Vector3)
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

return module