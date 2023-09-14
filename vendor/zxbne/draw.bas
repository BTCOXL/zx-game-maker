#include <memcopy.bas>

CONST screenHeight AS UBYTE = 8
CONST screenWidth AS UBYTE = 16
CONST screenCount AS UBYTE = 2

Dim currentScreen as UBYTE = 0
Dim currentLife as UBYTE = 100
Dim currentKeys as UBYTE = 0
Dim currentItems as UBYTE = 0

function getCell(row as UBYTE, col as UBYTE) AS UBYTE
	return screens(currentScreen, row, col) - 1
end function

sub mapDraw()
	dim counter as ubyte = 0
	for row=0 to screenHeight - 1
		for col=0 to screenWidth - 1
		    dim cell as UBYTE = getCell(row, col)
			counter = counter + 1
			if cell = 0
				NIRVANAfillT(0, (row + 1) * 16, col * 2)
			else
				NIRVANAdrawT(cell, (row + 1) * 16, col * 2)
			end if
		next col
	next row
end sub

sub redrawScreen()
	NIRVANAstop()
	memset(22527,0,768)
	mapDraw()
	NIRVANAstart()
	printLife()
	enemiesDraw(currentScreen)
end sub

function getCellByNirvanaPosition(lin as UBYTE, col as UBYTE) AS UBYTE
	lin = (lin / 16) - 1
	col = col / 2

	return getCell(lin, col)
end function

SUB drawCell(cell as UBYTE, lin as UBYTE, col as UBYTE)
	if cell = 0
		NIRVANAfillT(0, lin, col)
	else
		NIRVANAdrawT(cell, lin, col)
	end if
end sub

sub drawToScr(lin as UBYTE, col as UBYTE, isColPair AS UBYTE)
	NIRVANAhalt()
	' drawCell(getCellByNirvanaPosition(lin, col), lin, col)
	if isColPair
		drawCell(getCellByNirvanaPosition(lin, col), lin, col)
	else
		drawCell(getCellByNirvanaPosition(lin, col - 1), lin, col - 1)
		drawCell(getCellByNirvanaPosition(lin, col + 1), lin, col + 1)
	end if
end sub

sub restoreScr(lin as UBYTE, col as UBYTE)
	NIRVANAhalt()
	drawCell(getCellByNirvanaPosition(lin, col), lin, col)
	drawCell(getCellByNirvanaPosition(lin, col - 1), lin, col - 1)
	drawCell(getCellByNirvanaPosition(lin, col - 2), lin, col - 2)
	drawCell(getCellByNirvanaPosition(lin, col + 1), lin, col + 1)
	' if col mod 2 = 0
	' 	drawCell(getCellByNirvanaPosition(lin, col), lin, col)
	' else
	' 	drawCell(getCellByNirvanaPosition(lin, col - 1), lin, col - 1)
	' 	drawCell(getCellByNirvanaPosition(lin, col + 1), lin, col + 1)
	' end if
end sub

sub decrementLife()
	if (currentLife = 0)
		return
	end if

	if currentLife > 5 then
		currentLife = currentLife - 5
	else
		currentLife = 0
	end if
	printLife()
end sub

sub incrementKeys()
	currentKeys = currentKeys + 1
	printLife()
end sub

sub incrementItems()
	currentItems = currentItems + 1
	printLife()
end sub

sub printLife()
	PRINT AT 0, 0; "Life:"
	PRINT AT 0, 5; "   "
	PRINT AT 0, 5; currentLife
	PRINT AT 0, 10; "Keys:"
	PRINT AT 0, 15; " "
	PRINT AT 0, 15; currentKeys
	PRINT AT 0, 20; "Items:"
	PRINT AT 0, 26; " "
	PRINT AT 0, 26; currentItems
end sub

sub drawMenu()
	PRINT AT 0, 5; "ZX BASIC NIRVANA ENGINE"
	PRINT AT 5, 5; "PRESS ANY KEY TO START"
end sub

sub debug(message as string)
	PRINT AT 0, 10; "                         "
	PRINT AT 0, 10; message
end sub

sub moveToScreen(direction as Ubyte)
	removeAllObjects()
	if direction = 6
		setNewState(getNewSpriteStateLin(0), 1, getNewSpriteStateTile(0))
		currentScreen = currentScreen + 1
	elseif direction = 4
		setNewState(getNewSpriteStateLin(0), 29, getNewSpriteStateTile(0))
		currentScreen = currentScreen - 1
	elseif direction = 2
		setNewState(0, getNewSpriteStateCol(0), getNewSpriteStateTile(0))
		currentScreen = currentScreen + MAP_SCREENS_WIDTH_COUNT
	elseif direction = 8
		setNewState(MAX_LINE, getNewSpriteStateCol(0), getNewSpriteStateTile(0))
		startJumping()
		currentScreen = currentScreen - MAP_SCREENS_WIDTH_COUNT
	end if
	redrawScreen()
end sub

sub drawSprites()
	sprite = isAKey(getNewSpriteStateLin(0), col)
	if sprite
		killEnemy(sprite, isColPair, 0)
		incrementKeys()
	end if

	sprite = isAnItem(getNewSpriteStateLin(0), col)
	if sprite
		killEnemy(sprite, isColPair, 0)
		incrementItems()
	end if
	restoreScr(getOldSpriteStateLin(0), getOldSpriteStateCol(0))
	debugA(getNewSpriteStateCol(0))
	if getNewSpriteStateCol(0) = 0
		moveToScreen(4)
	else if getNewSpriteStateCol(0) = 30
		moveToScreen(6)
	end if
	debugA(getNewSpriteStateCol(0))
	NIRVANAspriteT(0, getNewSpriteStateTile(0), getNewSpriteStateLin(0), getNewSpriteStateCol(0))
END SUB