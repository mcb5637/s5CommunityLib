if mcbPacker then --mcbPacker.ignore
end --mcbPacker.ignore


--[[---------------------------------------------

**********************************************************************************

Simplex Noise Module, Translated by Levybreak

Modified by Jared "Nergal" Hewitt for use with MapGen for Love2D

Original Source: http://staffwww.itn.liu.se/~stegu/simplexnoise/simplexnoise.pdf

	The code there is in java, the original implementation by Ken Perlin

**********************************************************************************

--]] ---------------------------------------------

--- author:Levybreak,Jared "Nergal" Hewitt,RobbiTheFox, mcb		current maintainer:RobbiTheFox		v1.0
--
SimplexNoise = {}
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SimplexNoise.Gradients3D = { { 1, 1, 0 }, { -1, 1, 0 }, { 1, -1, 0 }, { -1, -1, 0 },
	{ 1, 0, 1 }, { -1, 0, 1 }, { 1, 0, -1 }, { -1, 0, -1 },
	{ 0, 1, 1 }, { 0, -1, 1 }, { 0, 1, -1 }, { 0, -1, -1 } }

for i = 1, table.getn(SimplexNoise.Gradients3D) do
	SimplexNoise.Gradients3D[i - 1] = SimplexNoise.Gradients3D[i]
	SimplexNoise.Gradients3D[i] = nil
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function SimplexNoise.seedP(seed)
	local s2 = seed * 1234567

	-- reset all the things
	SimplexNoise.p = {}
	SimplexNoise.Prev2D = {}
	SimplexNoise.PrevBlur2D = {}

	SimplexNoise.GRAD_X =
	{
		1, -1, 1, -1,
		1, -1, 1, -1,
		0, 0, 0, 0
	}
	SimplexNoise.GRAD_Y =
	{
		1, 1, -1, -1,
		0, 0, 0, 0,
		1, -1, 1, -1
	}

	for i = 1, 12 do
		SimplexNoise.GRAD_X[i - 1] = SimplexNoise.GRAD_X[i]
		SimplexNoise.GRAD_X[i] = nil
		SimplexNoise.GRAD_Y[i - 1] = SimplexNoise.GRAD_Y[i]
		SimplexNoise.GRAD_Y[i] = nil
	end

	local r = 0
	for i = 1, 256 do
		SimplexNoise.p[i] = math.mod((s2 + math.floor(s2 / i)), 256)
	end
	-- To remove the need for index wrapping, double the permutation table length
	for i = 1, table.getn(SimplexNoise.p) do
		SimplexNoise.p[i - 1] = SimplexNoise.p[i]
		SimplexNoise.p[i] = nil
	end

	SimplexNoise.perm = {}
	for i = 0, 255 do
		SimplexNoise.perm[i] = i
	end

	SimplexNoise.perm12 = {}
	local rng
	local k
	local l
	local temp

	for j = 0, 255 do
		--SimplexNoise.perm[j] = SimplexNoise.p[j]
		--SimplexNoise.perm[j+256] = SimplexNoise.p[j]

		rng = math.mod(s2, 256 - j)
		k = rng + j
		l = SimplexNoise.perm[j]
		temp = SimplexNoise.perm[k]
		SimplexNoise.perm[j] = temp
		SimplexNoise.perm[j + 256] = temp
		SimplexNoise.perm[k] = l
		temp = math.mod(SimplexNoise.perm[j], 12)
		SimplexNoise.perm12[j] = temp
		SimplexNoise.perm12[j + 256] = temp
	end

	SimplexNoise.RandomKey = 0
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SimplexNoise.Dot2D = function(tbl, x, y)
	return tbl[1] * x + tbl[2] * y
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--SimplexNoise.Prev2D = {}
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2D simplex noise
SimplexNoise.Noise2D = function(offset, xin, yin)
	--if SimplexNoise.Prev2D[xin] and SimplexNoise.Prev2D[xin][yin] then return SimplexNoise.Prev2D[xin][yin] end

	local n0, n1, n2 -- Noise contributions from the three corners
	-- Skew the input space to determine which simplex cell we're in
	local F2 = 0.5 * (math.sqrt(3.0) - 1.0)
	local s = (xin + yin) * F2 -- Hairy factor for 2D
	local i = math.floor(xin + s)
	local j = math.floor(yin + s)
	local G2 = (3.0 - math.sqrt(3.0)) / 6.0

	local t = (i + j) * G2
	local X0 = i - t -- Unskew the cell origin back to (x,y) space
	local Y0 = j - t
	local x0 = xin - X0 -- The x,y distances from the cell origin
	local y0 = yin - Y0

	-- For the 2D case, the simplex shape is an equilateral triangle.
	-- Determine which simplex we are in.
	local i1, j1; -- Offsets for second (middle) corner of simplex in (i,j) coords
	if (x0 > y0) then
		i1 = 1
		j1 = 0 -- lower triangle, XY order: (0,0)->(1,0)->(1,1)
	else
		i1 = 0
		j1 = 1 -- upper triangle, YX order: (0,0)->(0,1)->(1,1)
	end

	-- A step of (1,0) in (i,j) means a step of (1-c,-c) in (x,y), and
	-- a step of (0,1) in (i,j) means a step of (-c,1-c) in (x,y), where
	-- c = (3-sqrt(3))/6

	local x1 = x0 - i1 + G2 -- Offsets for middle corner in (x,y) unskewed coords
	local y1 = y0 - j1 + G2
	local x2 = x0 - 1.0 + 2.0 * G2 -- Offsets for last corner in (x,y) unskewed coords
	local y2 = y0 - 1.0 + 2.0 * G2

	-- Work out the hashed gradient indices of the three simplex corners
	local ii = bit32.band(i, 255)
	local jj = bit32.band(j, 255)
	local gi0 = math.mod(SimplexNoise.perm[ii + SimplexNoise.perm[jj]], 12)
	local gi1 = math.mod(SimplexNoise.perm[ii + i1 + SimplexNoise.perm[jj + j1]], 12)
	local gi2 = math.mod(SimplexNoise.perm[ii + 1 + SimplexNoise.perm[jj + 1]], 12)

	-- Calculate the contribution from the three corners
	local t0 = 0.5 - x0 * x0 - y0 * y0
	if t0 < 0 then
		n0 = 0.0;
	else
		t0 = t0 * t0
		n0 = t0 * t0 * SimplexNoise.GradCoord2D(offset, i, j, x0, y0) --SimplexNoise.Dot2D(SimplexNoise.Gradients3D[gi0], x0, y0) -- (x,y) of Gradients3D used for 2D gradient
	end

	local t1 = 0.5 - x1 * x1 - y1 * y1;
	if (t1 < 0) then
		n1 = 0.0
	else
		t1 = t1 * t1
		n1 = t1 * t1 * SimplexNoise.GradCoord2D(offset, i + i1, j + j1, x1, y1) --SimplexNoise.Dot2D(SimplexNoise.Gradients3D[gi1], x1, y1)
	end

	local t2 = 0.5 - x2 * x2 - y2 * y2;
	if (t2 < 0) then
		n2 = 0.0
	else
		t2 = t2 * t2
		n2 = t2 * t2 * SimplexNoise.GradCoord2D(offset, i + 1, j + 1, x2, y2) --SimplexNoise.Dot2D(SimplexNoise.Gradients3D[gi2], x2, y2)
	end

	-- Add contributions from each corner to get the final noise value.
	-- The result is scaled to return values in the localerval [-1,1].

	local retval = 70.0 * (n0 + n1 + n2)

	--if not SimplexNoise.Prev2D[xin] then SimplexNoise.Prev2D[xin] = {} end
	--SimplexNoise.Prev2D[xin][yin] = retval

	return retval
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SimplexNoise.GradCoord2D = function(offset, x, y, xd, yd)
	local lutPos = SimplexNoise.Index2D_12(offset, x, y)

	return xd * SimplexNoise.GRAD_X[lutPos] + yd * SimplexNoise.GRAD_Y[lutPos]
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SimplexNoise.Index2D_12 = function(offset, x, y)
	--return m_perm12[(x & 0xff) + m_perm[(y & 0xff) + offset]]
	return SimplexNoise.perm12[math.mod(x, 256) + SimplexNoise.perm[math.mod(y, 256) + offset]]
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SimplexNoise.e = 2.71828182845904523536
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SimplexNoise.PrevBlur2D = {}
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SimplexNoise.GBlur2D = function(x, y, stdDev)
	if SimplexNoise.PrevBlur2D[x] and SimplexNoise.PrevBlur2D[x][y] and SimplexNoise.PrevBlur2D[x][y][stdDev] then return SimplexNoise
		.PrevBlur2D[x][y][stdDev] end
	local pwr = ((x ^ 2 + y ^ 2) / (2 * (stdDev ^ 2))) * -1
	local ret = ((1 / (2 * math.pi * (stdDev ^ 2))) * 2.7) ^ pwr
	if not SimplexNoise.PrevBlur2D[x] then SimplexNoise.PrevBlur2D[x] = {} end
	if not SimplexNoise.PrevBlur2D[x][y] then SimplexNoise.PrevBlur2D[x][y] = {} end
	SimplexNoise.PrevBlur2D[x][y][stdDev] = ret
	return ret
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SimplexNoise.FractalSum2DNoise = function(x, y, itier) --very expensive, much more so that standard 2D noise.
	local ret = SimplexNoise.Noise2D(x, y)
	for i = 1, itier do
		local itier = 2 ^ itier
		ret = ret + (i / itier) * (SimplexNoise.Noise2D(x * (itier / i), y * (itier / i)))
	end
	return ret
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SimplexNoise.FractalSumAbs2DNoise = function(x, y, itier) --very expensive, much more so that standard 2D noise.
	local ret = math.abs(SimplexNoise.Noise2D(x, y))
	for i = 1, itier do
		local itier = 2 ^ itier
		ret = ret + (i / itier) * (math.abs(SimplexNoise.Noise2D(x * (itier / i), y * (itier / i))))
	end
	return ret
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SimplexNoise.Turbulent2DNoise = function(x, y, itier) --very expensive, much more so that standard 2D noise.
	local ret = math.abs(SimplexNoise.Noise2D(x, y))
	for i = 1, itier do
		local itier = 2 ^ itier
		ret = ret + (i / itier) * (math.abs(SimplexNoise.Noise2D(x * (itier / i), y * (itier / i))))
	end
	return math.sin(x + ret)
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SimplexNoise.GetRandomByNoise = function(_min, _max, _key)
	if not _max then
		if not _min then
			_max = 1
		else
			_max = _min
		end
		_min = 0
	end

	--SimplexNoise.Key = SimplexNoise.Key or 0
	--_key = SimplexNoise.Key
	--SimplexNoise.Key = SimplexNoise.Key + 1
	--_key = _key * 0.01

	local center = (_min + _max) / 2
	local r = _max - center
	local noise = math.floor(SimplexNoise.Noise2D(SimplexNoise.perm[1], _key, 1) * r + center + 0.5)

	--SimplexNoise.RandomKey = SimplexNoise.RandomKey + 1
	return noise
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[---------------
bit32 v0.4
-------------------
a bitwise operation lib for lua.
http://luaforge.net/projects/bit/
Modified for use with Love2D by Jared "Nergal" Hewitt
Under the MIT license.
copyright(c) 2006~2007 hanzhao (abrash_han@hotmail.com)
**********************************************************
--]]
---------------
--function InitBit32()
if not bit32 then
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
	bit32 = {}
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- bit lib implementions
	bit32.check_int = function(n)
		-- checking not float
		if (n - math.floor(n) > 0) then
			error("trying to use bitwise operation on non-integer!")
		end
	end
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	bit32.tobits = function(n)
		bit32.check_int(n)
		if (n < 0) then
			-- negative
			return bit32.tobits(bit32.bnot(math.abs(n)) + 1)
		end
		-- to bits table
		local tbl = {}
		local cnt = 1
		while (n > 0) do
			local last = math.mod(n, 2)
			if (last == 1) then
				tbl[cnt] = 1
			else
				tbl[cnt] = 0
			end
			n = (n - last) / 2
			cnt = cnt + 1
		end

		return tbl
	end
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	bit32.tonumb = function(tbl)
		local n = table.getn(tbl)

		local rslt = 0
		local power = 1
		for i = 1, n do
			rslt = rslt + tbl[i] * power
			power = power * 2
		end

		return rslt
	end
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	bit32.expand = function(tbl_m, tbl_n)
		local big = {}
		local small = {}
		if (table.getn(tbl_m) > table.getn(tbl_n)) then
			big = tbl_m
			small = tbl_n
		else
			big = tbl_n
			small = tbl_m
		end
		-- expand small
		for i = table.getn(small) + 1, table.getn(big) do
			small[i] = 0
		end
	end
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	bit32.bor = function(m, n)
		if not m then GUI.AddStaticNote("BOR: m") end
		if not n then GUI.AddStaticNote("BOR: n") end
		local tbl_m = bit32.tobits(m)
		local tbl_n = bit32.tobits(n)
		bit32.expand(tbl_m, tbl_n)

		local tbl = {}
		local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
		for i = 1, rslt do
			if (tbl_m[i] == 0 and tbl_n[i] == 0) then
				tbl[i] = 0
			else
				tbl[i] = 1
			end
		end

		return bit32.tonumb(tbl)
	end
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	bit32.band = function(m, n)
		if not m then GUI.AddStaticNote("BAND: m") end
		if not n then GUI.AddStaticNote("BAND: n") end
		local tbl_m = bit32.tobits(m)
		local tbl_n = bit32.tobits(n)
		bit32.expand(tbl_m, tbl_n)

		local tbl = {}
		local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
		for i = 1, rslt do
			if (tbl_m[i] == 0 or tbl_n[i] == 0) then
				tbl[i] = 0
			else
				tbl[i] = 1
			end
		end

		return bit32.tonumb(tbl)
	end
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	bit32.bnot = function(n)
		local tbl = bit32.tobits(n)
		local size = math.max(table.getn(tbl), 32)
		for i = 1, size do
			if (tbl[i] == 1) then
				tbl[i] = 0
			else
				tbl[i] = 1
			end
		end

		return bit32.tonumb(tbl)
	end
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	bit32.bxor = function(m, n)
		local tbl_m = bit32.tobits(m)
		local tbl_n = bit32.tobits(n)
		bit32.expand(tbl_m, tbl_n)

		local tbl = {}
		local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
		for i = 1, rslt do
			if (tbl_m[i] ~= tbl_n[i]) then
				tbl[i] = 1
			else
				tbl[i] = 0
			end
		end

		return bit32.tonumb(tbl)
	end
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	bit32.brshift = function(n, bits)
		bit32.check_int(n)

		local high_bit = 0
		if (n < 0) then
			-- negative
			n = bit32.bnot(math.abs(n)) + 1
			high_bit = 2147483648 -- 0x80000000
		end

		for i = 1, bits do
			n = n / 2
			n = bit32.bor(math.floor(n), high_bit)
		end

		return math.floor(n)
	end
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- logic rightshift assures zero filling shift
	bit32.blogic_rshift = function(n, bits)
		bit32.check_int(n)
		if (n < 0) then
			-- negative
			n = bit32.bnot(math.abs(n)) + 1
		end
		for i = 1, bits do
			n = n / 2
		end

		return math.floor(n)
	end
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	bit32.blshift = function(n, bits)
		bit32.check_int(n)

		if (n < 0) then
			-- negative
			n = bit32.bnot(math.abs(n)) + 1
		end

		for i = 1, bits do
			n = n * 2
		end

		return bit32.band(n, 4294967295) -- 0xFFFFFFFF
	end
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	bit32.bxor2 = function(m, n)
		local rhs = bit32.bor(bit32.bnot(m), bit32.bnot(n))
		local lhs = bit32.bor(m, n)
		local rslt = bit32.band(lhs, rhs)

		return rslt
	end
end
