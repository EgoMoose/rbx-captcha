--!strict

type Vector = {number}
type Matrix = {Vector}

local module = {}

-- Private

local function copy(A: Matrix): Matrix
	local M = {}
	for i = 1, #A do
		M[i] = {}
		for j = 1, #A[i] do
			M[i][j] = A[i][j]
		end
	end
	return M
end

local function decomposeLUP(A: Matrix): (Matrix, Vector)
	A = copy(A)

	local n = #A

	local pi = {}
	for i = 1, n do
		pi[i] = i
	end

	for k = 1, n do
		local k1 = 0
		local p = 0
		for i = k, n do
			local abs = math.abs(A[i][k])
			if abs > p then
				p = abs
				k1 = i
			end
		end

		if p == 0 then
			error("Singular matrix!")
		end

		pi[k], pi[k1] = pi[k1], pi[k]

		for i = 1, n do
			A[k][i], A[k1][i] = A[k1][i], A[k][i]
		end

		for i = k + 1, n do
			A[i][k] = A[i][k] / A[k][k]
			for j = k + 1, n do
				A[i][j] = A[i][j] - A[i][k] * A[k][j]
			end
		end
	end

	return A, pi
end

local function splitLU(A: Matrix): (Matrix, Matrix)
	local n = #A

	local L, U = {}, {}
	for i = 1, n do
		L[i], U[i] = {}, {}
		for j = 1, n do
			L[i][j], U[i][j] = 0, 0
		end
	end

	for i = 1, n do
		L[i][i] = 1
		for j = 1, i - 1 do
			L[i][j] = A[i][j]
		end
	end

	for i = 1, n do
		for j = i, n do
			U[i][j] = A[i][j]
		end
	end

	return L, U
end

-- Public

function module.solve(A: Matrix, b: Matrix): Vector
	local A1, pi = decomposeLUP(A)
	local L, U = splitLU(A1)

	local n = #A
	local x, y = {}, {}
	for i = 1, n do
		x[i], y[i] = 0, 0
	end

	for i = 1, n do
		local sum = 0
		for j = 1, i do
			sum = sum + L[i][j] * y[j]
		end
		y[i] = b[pi[i]][1] - sum
	end

	for i = n, 1, -1 do
		local sum = 0
		for j = i + 1, n do
			sum = sum + U[i][j] * x[j]
		end
		x[i] = (y[i] - sum) / U[i][i]
	end

	return x
end

function module.multiply(A: Matrix, B: Matrix): Matrix
	local M = {}
	for i = 1, #A do
		M[i] = {}
		for j = 1, #B[1] do
			local c = A[i][1] * B[1][j]
			for n = 2, #A[1] do
				c = c + A[i][n] * B[n][j]
			end
			M[i][j] = c
		end
	end
	return M
end

--

return module