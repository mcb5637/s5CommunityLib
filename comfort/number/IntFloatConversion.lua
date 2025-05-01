--------------------------------------------------------------------------------
-- int/float conversion
-- author: Kantelo/Bobby?
-- current maintainer: RobbiTheFox
-- Version: v1.0
--------------------------------------------------------------------------------
function Float2Int(fval)
    if(fval == 0) then
        return 0
    end

    local frac, exp = math.frexp(fval)

    local signSub = 0
    if(frac < 0) then
        frac = frac * -1
        signSub = 2147483648
    end

    local outVal = 0
    local bitVal = 4194304

    frac = frac * 4 - 2
    for i = 1, 23 do
        if(frac >= 1) then
            outVal = outVal + bitVal
            frac = frac - 1
        end
        if(frac == 0) then
            break
        end
        bitVal = bitVal / 2
        frac = frac * 2
    end
    if(frac >= 1) then
        outVal = outVal + 1
    end

    return outVal + (exp+126)*8388608 - signSub
end
--------------------------------------------------------------------------------
function Int2Float(inum)
    if(inum == 0) then
        return 0
    end

    local sign = 1
    if(inum < 0) then
        inum = 2147483648 + inum
        sign = -1
    end

    local frac = math.mod(inum, 8388608)
    local exp = (inum-frac)/8388608 - 127
    local fraction = 1
    local fracVal = 0.5
    local bitVal = 4194304
    for i = 23, 1, -1 do
        if(frac - bitVal) > 0 then
            fraction = fraction + fracVal
            frac = frac - bitVal
        end
        bitVal = bitVal / 2
        fracVal = fracVal / 2
    end
    fraction = fraction + fracVal * frac * 2
    return math.ldexp(fraction, exp) * sign
end