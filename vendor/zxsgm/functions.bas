sub decrementLife()
	if (currentLife = 0)
		return
	end if

	if currentLife > DAMAGE_AMOUNT then
		currentLife = currentLife - DAMAGE_AMOUNT
	else
		currentLife = 0
	end if
	printLife()
end sub

sub incrementItems()
	currentItems = currentItems + 1
	printLife()
	if currentItems >= GOAL_ITEMS
		go to ending
	end if
end sub

sub printLife()
	PRINT AT 22, 5; "  "  
	PRINT AT 22, 5; currentLife
	PRINT AT 22, 16; currentKeys
	PRINT AT 22, 30; currentItems
end sub

function secureXIncrement(x as integer, increment as integer) as integer
    dim result as integer = x + increment

    if result < 0 or result > 60
        return x
    end if

    return result
end function

function secureYIncrement(y as integer, increment as integer) as integer
    dim result as integer = y + increment

    if result < 0 or result > MAX_LINE + 4
        return y
    end if
    
    return result
end function

function InArray(Needle as uByte, Haystack as uInteger, arraySize as ubyte) as ubyte
	dim value as uByte
	for i = 0 to arraySize
		value = peek(Haystack + i)
		if value = Needle
			return value
		end if
	next i

	return 0
end function

function isADamageTile(tile as ubyte) as UBYTE
	for i = 0 to DAMAGE_TILES_ARRAY_SIZE
		if InArray(tile, @damageTiles, DAMAGE_TILES_ARRAY_SIZE)
			return 1
		end if
	next i
	return 0
end function

function isSolidTileByColLin(col as ubyte, lin as ubyte) as ubyte
	dim tile as ubyte = GetTile(col, lin)

    if tile > 0 and tile < 64 'is solid tile
        if not invincible then
            if isADamageTile(tile)
                protaTouch()
            end if
        end if
        return 1
    end if
	return 0
end function

sub protaTouch()
    invincible = 1
    invincibleFrame = framec
    decrementLife()
    damageSound()
end sub

function CheckCollision(x as uByte, y as uByte) as uByte
    Dim xIsEven as uByte = (x bAnd 1) = 0
    Dim yIsEven as uByte = (y bAnd 1) = 0
    Dim col as uByte = x >> 1
    Dim lin as uByte = y >> 1

    if xIsEven and yIsEven
        if isSolidTileByColLin(col, lin) then return 1
		if isSolidTileByColLin(col + 1, lin) then return 1
    	if isSolidTileByColLin(col, lin + 1) then return 1
		if isSolidTileByColLin(col + 1, lin + 1) then return 1
    elseif xIsEven and not yIsEven
        if isSolidTileByColLin(col, lin) then return 1
		if isSolidTileByColLin(col + 1, lin) then return 1
        if isSolidTileByColLin(col, lin + 1) then return 1
		if isSolidTileByColLin(col + 1, lin + 1) then return 1
    	if isSolidTileByColLin(col, lin + 2) then return 1
		if isSolidTileByColLin(col + 1, lin + 2) then return 1
	elseif not xIsEven and yIsEven
		if isSolidTileByColLin(col, lin) then return 1
		if isSolidTileByColLin(col + 1, lin) then return 1
		if isSolidTileByColLin(col + 2, lin) then return 1
		if isSolidTileByColLin(col, lin + 1) then return 1
		if isSolidTileByColLin(col + 1, lin + 1) then return 1
		if isSolidTileByColLin(col + 2, lin + 1) then return 1
    elseif not xIsEven and not yIsEven
        if isSolidTileByColLin(col, lin) then return 1
		if isSolidTileByColLin(col + 1, lin) then return 1
		if isSolidTileByColLin(col + 2, lin) then return 1
    	if isSolidTileByColLin(col, lin + 1) then return 1
		if isSolidTileByColLin(col + 1, lin + 1) then return 1
		if isSolidTileByColLin(col + 2, lin + 1) then return 1
        if isSolidTileByColLin(col, lin + 2) then return 1
		if isSolidTileByColLin(col + 1, lin + 2) then return 1
		if isSolidTileByColLin(col + 2, lin + 2) then return 1
    end if
	return 0
end function

function isSolidTileByXY(x as ubyte, y as ubyte) as ubyte
    dim col as uByte = x >> 1
    dim lin as uByte = y >> 1
    
    dim tile as ubyte = GetTile(col, lin)

	return tile > 0 and tile < 64 ' is solid tile
end function

Function fastcall hMirror (number as uByte) as uByte
asm
;17 bytes and 66 clock cycles
Reverse:
    ld b,a       ;b=ABCDEFGH
    rrca         ;a=HABCDEFG
    rrca         ;a=GHABCDEF
    xor b
    and %10101010
    xor b        ;a=GBADCFEH
    ld b,a       ;b=GBADCFEH
    rrca         ;a=HGBADCFE
    rrca         ;a=EHGBADCF
    rrca         ;a=FEHGBADC
    rrca         ;a=CFEHGBAD
    xor b
    and %01100110
    xor b        ;a=GFEDCBAH
    rrca         ;a=HGFEDCBA
end asm
end function

#ifdef INIT_TEXTS
    sub showInitTexts(Text as String)
        dim n as uByte
        dim line = ""
        dim word = ""
        dim y = 1
        dim x = 0
        cls
        for n=0 to len(Text)-1
            let c = Text(n to n)
            if c = " " or n = len(Text) - 1 then
                if len(line + word) > 31 then
                    print at y, 0; line
                    beep .01,0
                    let line = word
                    if c = " " then
                        let line = line + " "
                    end if
                    let y = y + 1
                    let x = 0
                else
                    let line = line + word
                    if c = " " then
                        let line = line + " "
                    end if
                end if
                let word = ""
            else
                let word = word + c
            end if
        next n
        if line <> "" then
            print at y, x; line
        end if
        while INKEY$<>"":wend
        while INKEY$="":wend
    end sub
#endif