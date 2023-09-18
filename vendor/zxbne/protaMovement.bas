#include <keys.bas>

dim landed as UBYTE
dim isColPair as UBYTE = 1
dim burnToClean as UBYTE = 0
dim yStepSize = 16

function isSolidTile(lin as UBYTE, col as UBYTE) as UBYTE
	dim tile as UBYTE = getCellByNirvanaPosition(lin, col)

	if tile = 1 OR tile = 2
		return 1
    end if
	    
	return 0
end function

function canMoveLeft() as UBYTE
	if (isColPair)
		return getNewSpriteStateCol(0) > 0 AND isSolidTile(getNewSpriteStateLin(0), getNewSpriteStateCol(0) - 2) <> 1
	end if
		
	return getNewSpriteStateCol(0) > 0 AND isSolidTile(getNewSpriteStateLin(0), getNewSpriteStateCol(0) - 1) <> 1
end function

function canMoveRight() as UBYTE
	if (isColPair)
		return getNewSpriteStateCol(0) < 30 AND isSolidTile(getNewSpriteStateLin(0), getNewSpriteStateCol(0) + 2) <> 1
	end if

	return getNewSpriteStateCol(0) < 30 AND isSolidTile(getNewSpriteStateLin(0), getNewSpriteStateCol(0) + 1) <> 1
end function

function canMoveUp() as UBYTE
	return isSolidTile(getNewSpriteStateLin(0) - 16, getNewSpriteStateCol(0)) <> 1
end function

function onTheSolidTile() as UBYTE
	dim tile as UBYTE = getCellByNirvanaPosition(getNewSpriteStateLin(0) + 16, getNewSpriteStateCol(0))
	dim preTile as UBYTE = getCellByNirvanaPosition(getNewSpriteStateLin(0) + 16, getNewSpriteStateCol(0) - 1)
	dim postTile as UBYTE = getCellByNirvanaPosition(getNewSpriteStateLin(0) + 16, getNewSpriteStateCol(0) + 1)

	if tile = 1 OR tile = 2 OR preTile = 1 OR preTile = 2 OR postTile = 1 OR postTile = 2
		landed = 1
		return 1
	else
		return 0
	end if 
end function

sub checkIsJumping()
	if jumpCurrentKey <> jumpStopValue
		if getNewSpriteStateLin(0) = 0
			moveToScreen(8)
		elseif jumpCurrentKey > 0 and onTheSolidTile()
			stopJumping()
		elseif jumpCurrentKey < jumpStepsCount AND canMoveUp()
			updateState(getNewSpriteStateLin(0) + jumpArray(jumpCurrentKey), getNewSpriteStateCol(0), getNewSpriteStateTile(0), getNewSpriteStateDirection(0))
			jumpCurrentKey = jumpCurrentKey + 1
		else
			stopJumping()
        end if
	end if
end sub

function isFalling() as UBYTE
	if onTheSolidTile() <> 1
		return 1
	else
		return 0
	end if
end function

sub gravity()
	if jumpCurrentKey = jumpStopValue and isFalling()
		'debug ("falling")
		if getNewSpriteStateLin(0) = MAX_LINE
			moveToScreen(2)
		else
			updateState(getNewSpriteStateLin(0) + yStepSize, getNewSpriteStateCol(0), getNewSpriteStateTile(0), getNewSpriteStateDirection(0))
			sprite = isAnEnemy(getNewSpriteStateLin(0), getNewSpriteStateCol(0))
			if sprite
				killEnemy(sprite, isColPair, 1)
				startJumping()
				burnToClean = sprite
			end if
		end if
	end if
end sub

function getNextFrameRunning() as UBYTE
	if (getNewSpriteStateDirection(0))
		if getOldSpriteStateTile(0) = 50
			return 51
        elseif getOldSpriteStateTile(0) = 51
			return 52
        elseif getOldSpriteStateTile(0) = 52
			return 53
		else
			return 50
		end if
	else
        if getOldSpriteStateTile(0) = 54
            return 55
        elseif getOldSpriteStateTile(0) = 55
            return 56
        elseif getOldSpriteStateTile(0) = 56
            return 57
        else
            return 54
        end if
	end if
end function

sub keyboardListen()
    if MultiKeys(KEYO)<>0
		if canMoveLeft()
			updateState(getNewSpriteStateLin(0), getNewSpriteStateCol(0) - 1, getNextFrameRunning(), 0)
			setColPair(getNewSpriteStateCol(0) - 1)
			checkMoveScreen()
        end if
    END IF
    if MultiKeys(KEYP)<>0
		if canMoveRight()
			updateState(getNewSpriteStateLin(0), getNewSpriteStateCol(0) + 1, getNextFrameRunning(), 1)
			setColPair(getNewSpriteStateCol(0) + 1)
			checkMoveScreen()
        end if
    END IF
    if MultiKeys(KEYQ)<>0
        if !isJumping() and landed
			landed = 0
			startJumping()
        end if
    END IF
    if MultiKeys(KEYA)<>0

    END IF
end sub

sub checkMoveScreen()
	if onLastColumn(0) = 1
		print "last column"
		moveToScreen(6)
	else if onFirstColumn(0) = 1
		moveToScreen(4)
	end if
end sub

sub setColPair(col as ubyte)
	if col mod 2 = 0
		isColPair = 1
	else
		isColPair = 0
	end if
end sub

function getNextFrameJumpingFalling() as UBYTE
	if (getNewSpriteStateDirection(0))
		return 58
	else
		return 59
    end if
end function

sub updateState(lin as ubyte, col as ubyte, frameTile as ubyte, directionRight as ubyte)
	if isSolidTile(lin, col) <> 1
		saveOldSpriteState(0, getNewSpriteStateLin(0), getNewSpriteStateCol(0), getNewSpriteStateTile(0), getNewSpriteStateDirection(0))
		saveNewSpriteState(0, lin, col, frameTile, directionRight)
	end if
end sub

sub removePlayer()
	NIRVANAspriteT(0, 29, 0, 0)
end sub

sub checkItemContact()
	dim tile as UBYTE = getCellByNirvanaPosition(getNewSpriteStateLin(0), getNewSpriteStateCol(0))

	if tile = 18
		incrementItems()
	end if
end sub

sub checkKeyContact()
	dim tile as UBYTE = getCellByNirvanaPosition(getNewSpriteStateLin(0), getNewSpriteStateCol(0))

	if tile = 19
		incrementKeys()
	end if
end sub

sub protaMovement()
	keyboardListen()
	' checkItemContact()
	' checkKeyContact()
	checkIsJumping()
	gravity()
end sub