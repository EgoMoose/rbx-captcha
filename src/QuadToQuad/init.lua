
--!strict

local MatrixHelper = require(script:WaitForChild("MatrixHelper"))

export type Quad = {
	TopLeft: Vector3,
	TopRight: Vector3,
	BottomLeft: Vector3,
	BottomRight: Vector3,
}

local UNIFORM_SQUARE = {
	TopLeft = Vector3.new(0, 0),
	TopRight = Vector3.new(1, 0),
	BottomRight = Vector3.new(1, 1),
	BottomLeft = Vector3.new(0, 1),
}

local module = {}

function module.quadToQuad(quadP: Quad, quadQ: Quad): (Vector3) -> (Vector3)
	local p1, p2, p3, p4 = quadP.TopLeft, quadP.TopRight, quadP.BottomRight, quadP.BottomLeft
	local q1, q2, q3, q4 = quadQ.TopLeft, quadQ.TopRight, quadQ.BottomRight, quadQ.BottomLeft

	local A = {
		{p1.X, p1.Y, 1, 0, 0, 0, -p1.X*q1.X, -p1.Y*q1.X},
		{0, 0, 0, p1.X, p1.Y, 1, -p1.X*q1.Y, -p1.Y*q1.Y},
		{p2.X, p2.Y, 1, 0, 0, 0, -p2.X*q2.X, -p2.Y*q2.X},
		{0, 0, 0, p2.X, p2.Y, 1, -p2.X*q2.Y, -p2.Y*q2.Y},
		{p3.X, p3.Y, 1, 0, 0, 0, -p3.X*q3.X, -p3.Y*q3.X},
		{0, 0, 0, p3.X, p3.Y, 1, -p3.X*q3.Y, -p3.Y*q3.Y},
		{p4.X, p4.Y, 1, 0, 0, 0, -p4.X*q4.X, -p4.Y*q4.X},
		{0, 0, 0, p4.X, p4.Y, 1, -p4.X*q4.Y, -p4.Y*q4.Y},
	}

	local Q = {
		{q1.X},
		{q1.Y},
		{q2.X},
		{q2.Y},
		{q3.X},
		{q3.Y},
		{q4.X},
		{q4.Y},
	}

	local solved = MatrixHelper.solve(A, Q)

	local T = {
		{solved[1], solved[2], solved[3]},
		{solved[4], solved[5], solved[6]},
		{solved[7], solved[8], 1},
	}

	return function(vertex: Vector3)
		local v = MatrixHelper.multiply(T, {
			{vertex.X},
			{vertex.Y},
			{1},
		})

		local x, y, w = v[1][1], v[2][1], v[3][1]
		return Vector3.new(x / w, y / w)
	end
end

function module.uniformSquareToQuad(quad: Quad)
	return module.quadToQuad(UNIFORM_SQUARE, quad)
end

return module