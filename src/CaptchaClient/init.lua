--!strict

local Request = script:WaitForChild("Request")
local Respond = script:WaitForChild("Respond")

local module = {}

local CAMERA_DIRECTION = CFrame.fromEulerAnglesYXZ(0, math.pi, 0)

-- Private

local function getBounds(aabb: BasePart): {Vector3}
	local cf = aabb.CFrame
	local size2 = aabb.Size / 2

	return {
		cf:PointToObjectSpace(size2 * Vector3.new(-1, -1, 0)),
		cf:PointToObjectSpace(size2 * Vector3.new(1, -1, 0)),
		cf:PointToObjectSpace(size2 * Vector3.new(1, 1, 0)),
		cf:PointToObjectSpace(size2 * Vector3.new(-1, 1, 0)),
	}
end

local function viewProjectionEdgeHits(cloud: {Vector3}, axis: "X" | "Y", depth: number, tanFov2: number)
	local max, min = -math.huge, math.huge

	for _, lp in pairs(cloud) do
		local distance = depth - lp.Z
		local halfSpan = tanFov2 * distance

		local a = (lp :: any)[axis] + halfSpan
		local b = (lp :: any)[axis] - halfSpan

		max = math.max(max, a, b)
		min = math.min(min, a, b)
	end

	return max, min
end

local function getMinimumFitCFrame(orientation: CFrame, model: Model, vpf: ViewportFrame, camera: Camera): CFrame
	local vpfSize = vpf.AbsoluteSize
	local aspect = vpfSize.X / vpfSize.Y

	local yFov2 = math.rad(camera.FieldOfView / 2)
	local tanyFov2 = math.tan(yFov2)
		
	local xFov2 = math.atan(tanyFov2 * aspect)
	local tanxFov2 = math.tan(xFov2)

	local rotation = orientation - orientation.Position
	local rInverse = rotation:Inverse()

	local aabb = model:WaitForChild("AABB") :: BasePart
	local wcloud = getBounds(aabb)
	local cloud = {rInverse * wcloud[1]}
	local furthest = cloud[1].Z

	for i = 2, #wcloud do
		local lp = rInverse * wcloud[i]
		furthest = math.min(furthest, lp.Z)
		cloud[i] = lp
	end
	
	local hMax, hMin = viewProjectionEdgeHits(cloud, "X", furthest, tanxFov2)
	local vMax, vMin = viewProjectionEdgeHits(cloud, "Y", furthest, tanyFov2)

	local distance = math.max(
		((hMax - hMin) / 2) / tanxFov2,
		((vMax - vMin) / 2) / tanyFov2
	)

	return orientation * CFrame.new(
		(hMax + hMin) / 2,
		(vMax + vMin) / 2,
		furthest + distance
	)
end

-- Public

module.onRequest = Request.OnClientEvent

function module.respond(unique: string, answer: string): boolean
	return not not Respond:InvokeServer(unique, answer)
end

function module.fit(model: Model, vpf: ViewportFrame, camera: Camera)
	camera.CFrame = getMinimumFitCFrame(CAMERA_DIRECTION, model, vpf, camera)
end

--

return module