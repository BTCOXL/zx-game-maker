#include <keys.bas>

dim landed as UBYTE
dim burnToClean as UBYTE = 0
dim yStepSize as ubyte = 16

function canMoveLeft() as UBYTE
	dim col as ubyte = getOldSpriteStateCol(0)
	if isPair(col) = 0
		col = col + 1
	end if
	if getOldSpriteStateCol(0) > 0 AND isSolidTile(getOldSpriteStateLin(0), col - 2) <> 1
		return 1
	else
		return 0
	end if
end function

function canMoveRight() as UBYTE
	dim col as ubyte = getOldSpriteStateCol(0)
	if isPair(col) = 0
		col = col - 1
	end if
	if getOldSpriteStateCol(0) < 30 AND isSolidTile(getOldSpriteStateLin(0), col + 2) <> 1
		return 1
	else
		return 0
	end if
end function

function underSolidTile() as UBYTE
	dim tile as UBYTE = getCellByNirvanaPosition(getNewSpriteStateLin(0) - yStepSize, getNewSpriteStateCol(0))

	if tile = 1 OR tile = 2
		landed = 1
		return 1
	else
		if isPair(getNewSpriteStateCol(0)) = 1
			return 0
		end if

		dim preTile as UBYTE = getCellByNirvanaPosition(getNewSpriteStateLin(0) - yStepSize, getNewSpriteStateCol(0) - 1)
		dim postTile as UBYTE = getCellByNirvanaPosition(getNewSpriteStateLin(0) - yStepSize, getNewSpriteStateCol(0) + 1)
		if preTile = 1 OR preTile = 2 OR postTile = 1 OR postTile = 2
			return 1
		else
			return 0
		end if
	end if
end function

function onTheSolidTile() as UBYTE
	dim tile as UBYTE = getCellByNirvanaPosition(getNewSpriteStateLin(0) + yStepSize, getNewSpriteStateCol(0))

	if tile = 1 OR tile = 2
		landed = 1
		return 1
	else
		if isPair(getNewSpriteStateCol(0)) = 1
			return 0
		end if

		dim preTile as UBYTE = getCellByNirvanaPosition(getNewSpriteStateLin(0) + yStepSize, getNewSpriteStateCol(0) - 1)
		dim postTile as UBYTE = getCellByNirvanaPosition(getNewSpriteStateLin(0) + yStepSize, getNewSpriteStateCol(0) + 1)
		if preTile = 1 OR preTile = 2 OR postTile = 1 OR postTile = 2
			landed = 1
			return 1
		else
			return 0
		end if
	end if
end function

sub checkIsJumping()
	if jumpCurrentKey <> jumpStopValue
		if getNewSpriteStateLin(0) = 0
			moveScreen = 8
		elseif jumpCurrentKey > 0 and onTheSolidTile() = 1
			stopJumping()
		elseif jumpCurrentKey < jumpStepsCount AND underSolidTile() = 0
			updateState(0, getNewSpriteStateLin(0) + jumpArray(jumpCurrentKey), getNewSpriteStateCol(0), getNewSpriteStateTile(0), getNewSpriteStateDirection(0))
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
			moveScreen = 2
		else
			updateState(0, getNewSpriteStateLin(0) + yStepSize, getNewSpriteStateCol(0), getNewSpriteStateTile(0), getNewSpriteStateDirection(0))
			sprite = isAnEnemy(getNewSpriteStateLin(0), getNewSpriteStateCol(0))
			if sprite
				killEnemy(sprite, 1)
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
			updateState(0, getNewSpriteStateLin(0), getNewSpriteStateCol(0) - 1, getNextFrameRunning(), 0)
        end if
		if onFirstColumn(0)
			moveScreen = 4
		end if
    END IF
    if MultiKeys(KEYP)<>0
		if canMoveRight()
			updateState(0, getNewSpriteStateLin(0), getNewSpriteStateCol(0) + 1, getNextFrameRunning(), 1)
        end if
		if onLastColumn(0)
			moveScreen = 6
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

function getNextFrameJumpingFalling() as UBYTE
	if (getNewSpriteStateDirection(0))
		return 58
	else
		return 59
    end if
end function

sub removePlayer()
	NIRVANAspriteT(0, 29, 0, 0)
end sub

sub checkItemContact()
	dim sprite as UBYTE = isAnItem(getNewSpriteStateLin(0), getNewSpriteStateCol(0))

	if sprite <> 0
		incrementItems()
		resetItems()
		killEnemy(sprite, 1)
	end if
end sub

sub checkKeyContact()
	dim sprite as UBYTE = isAKey(getNewSpriteStateLin(0), getNewSpriteStateCol(0))

	if sprite <> 0
		incrementKeys()
		resetKeys()
		killEnemy(sprite, 1)
	end if
end sub

sub protaMovement()
	if drawing = 0
		keyboardListen()
		checkItemContact()
		checkKeyContact()
		checkIsJumping()
		gravity()
	end if
end sub