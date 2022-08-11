--- all types of water.
--- note: the ids are usually positive, but due to a bug in the Logic funcs, only watertypes <= 15 are allowed.
--- the negative values bypass the check and then get truncated to the same 6 bit uint as the real id ((wt << 8) & 0x3F00).
WaterTypes = {
	WaterA = 1,-- & -63
	WaterB = 2,-- & -62
	WaterC = 3,-- & -61
	WaterD = 4,-- & -60
	WaterE = 5,-- & -59
	Mediterran_Ocean = 10,-- & -54
	Mediterran_River = 11,-- & -53
	Mediterran_Lake = 12,-- & -52
	Nordic_Swamp = -44,
	Evelance_Swamp = -34,
	Moor = -24,
	Moor_NonFreezing_Swamp = -23,
	Mediterran_NonFreezing_Shorewave = -19,
	European_NonFreezing_Shorewave = -14,
	European_Shorewave = -9,
}