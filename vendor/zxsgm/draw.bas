const MAX_ANIMATED_TILES as ubyte = 3

function removeScreenObject(type as ubyte) AS UBYTE
	screenObjects(currentScreen, type) = 0
end function

dim animatedTilesInScreen(2, 3) as ubyte

sub mapDraw()
	dim tile, index, y, x as integer
	dim animatedTilesCount as ubyte

	x = 0
	y = 0
	animatedTilesCount = 0

	for index = 0 to MAX_ANIMATED_TILES - 1
		animatedTilesInScreen(index, 0) = 0
		animatedTilesInScreen(index, 1) = 0
		animatedTilesInScreen(index, 2) = 0
		animatedTilesInScreen(index, 3) = 0
	next index
	
	for index=0 to SCREEN_LENGTH
		tile = decompressedMap(index) - 1
		drawTile(tile, x, y)

		if tile > 1
			if animatedTilesCount < MAX_ANIMATED_TILES
				if InArray(tile, @animatedTiles, ANIMATED_TILES_ARRAY_SIZE)
					animatedTilesInScreen(animatedTilesCount, 0) = tile
					animatedTilesInScreen(animatedTilesCount, 1) = x
					animatedTilesInScreen(animatedTilesCount, 2) = y
					animatedTilesInScreen(animatedTilesCount, 3) = 0
					animatedTilesCount = animatedTilesCount + 1
				end if
			end if
		end if

		x = x + 1
		if x = screenWidth
			x = 0
			y = y + 1
		end if
	next index
end sub

sub drawTile(tile as ubyte, x as ubyte, y as ubyte)
	if tile <> 0
		if tile = itemTile
			if screenObjects(currentScreen, SCREEN_OBJECT_ITEM_INDEX)
				SetTileChecked(tile, attrSet(tile), x, y)
			end if
		elseif tile = keyTile
			if screenObjects(currentScreen, SCREEN_OBJECT_KEY_INDEX)
				SetTileChecked(tile, attrSet(tile), x, y)
			end if
		elseif tile = doorTile
			if screenObjects(currentScreen, SCREEN_OBJECT_DOOR_INDEX)
				SetTileChecked(tile, attrSet(tile), x, y)
			end if
		elseif tile = lifeTile
			if screenObjects(currentScreen, SCREEN_OBJECT_LIFE_INDEX)
				SetTileChecked(tile, attrSet(tile), x, y)
			end if
		else
			SetTile(tile, attrSet(tile), x, y)
		end if
	end if
end sub

sub redrawScreen()
	' memset(22527,0,768)
	ClearScreen(7, 0, 0)
	dzx0Standard(HUD_SCREEN_ADDRESS, $4000)
	FillWithTile(0, 32, 22, 7, 0, 0)
	' clearBox(0,0,120,112)
	mapDraw()
	printLife()
	' enemiesDraw(currentScreen)
end sub

function checkTileIsDoor(col as ubyte, lin as ubyte) as ubyte
	if GetTile(col, lin) = doorTile
		if currentKeys <> 0
			currentKeys = currentKeys - 1
			printLife()
			removeScreenObject(SCREEN_OBJECT_DOOR_INDEX)
			BeepFX_Play(4)
			FillWithTileChecked(0, 1, 1, 7, col, lin)
			FillWithTileChecked(0, 1, 1, 7, col, lin + 1)
		end if
		return 1
	else
		return 0
	end if
end function

function CheckDoor(x as uByte, y as uByte) as uByte
    Dim xIsEven as uByte = (x bAnd 1) = 0
    Dim yIsEven as uByte = (y bAnd 1) = 0
    Dim col as uByte = x >> 1
    Dim lin as uByte = y >> 1

    if xIsEven and yIsEven
        return checkTileIsDoor(col, lin) or checkTileIsDoor(col + 1, lin) _
            or checkTileIsDoor(col, lin + 1) or checkTileIsDoor(col + 1, lin + 1)
    elseif xIsEven and not yIsEven
        return checkTileIsDoor(col, lin) or checkTileIsDoor(col + 1, lin) _
            or checkTileIsDoor(col, lin + 1) or checkTileIsDoor(col + 1, lin + 1) _
            or checkTileIsDoor(col, lin + 2) or checkTileIsDoor(col + 1, lin + 2)
	elseif not xIsEven and yIsEven
		return checkTileIsDoor(col, lin) or checkTileIsDoor(col + 1, lin) or checkTileIsDoor(col + 2, lin) _
			or checkTileIsDoor(col, lin + 1) or checkTileIsDoor(col + 1, lin + 1) or checkTileIsDoor(col + 2, lin + 1)
    elseif not xIsEven and not yIsEven
        return checkTileIsDoor(col, lin) or checkTileIsDoor(col + 1, lin) or checkTileIsDoor(col + 2, lin) _
            or checkTileIsDoor(col, lin + 1) or checkTileIsDoor(col + 1, lin + 1) or checkTileIsDoor(col + 2, lin + 1) _
            or checkTileIsDoor(col, lin + 2) or checkTileIsDoor(col + 1, lin + 2) or checkTileIsDoor(col + 2, lin + 2)
    end if
end function

sub moveToScreen(direction as Ubyte)
	' removeAllObjects()
	if direction = 6
		saveSprite(PROTA_SPRITE, getSpriteLin(PROTA_SPRITE), 0, getSpriteTile(PROTA_SPRITE), getSpriteDirection(PROTA_SPRITE))
		currentScreen = currentScreen + 1
	elseif direction = 4
		saveSprite(PROTA_SPRITE, getSpriteLin(PROTA_SPRITE), 60, getSpriteTile(PROTA_SPRITE), getSpriteDirection(PROTA_SPRITE))
		currentScreen = currentScreen - 1
	elseif direction = 2
		saveSprite(PROTA_SPRITE, 0, getSpriteCol(PROTA_SPRITE), getSpriteTile(PROTA_SPRITE), getSpriteDirection(PROTA_SPRITE))
		currentScreen = currentScreen + MAP_SCREENS_WIDTH_COUNT
	elseif direction = 8
		saveSprite(PROTA_SPRITE, MAX_LINE, getSpriteCol(PROTA_SPRITE), getSpriteTile(PROTA_SPRITE), getSpriteDirection(PROTA_SPRITE))
		jumpCurrentKey = 0
		currentScreen = currentScreen - MAP_SCREENS_WIDTH_COUNT
	end if

	swapScreen()
	' removeScreenObjectFromBuffer()
	redrawScreen()
end sub

sub drawSprites()
	if not invincible
		Draw2x2Sprite(spritesSet(getSpriteTile(PROTA_SPRITE)), getSpriteCol(PROTA_SPRITE), getSpriteLin(PROTA_SPRITE))
	else
		if invincibleBlink
			invincibleBlink = not invincibleBlink
			Draw2x2Sprite(spritesSet(getSpriteTile(PROTA_SPRITE)), getSpriteCol(PROTA_SPRITE), getSpriteLin(PROTA_SPRITE))
		else
			invincibleBlink = not invincibleBlink
		end if
	end if
	if enemiesPerScreen(currentScreen) > 0
		dim xToPaint, yToPaint as float
		dim paintWidth as byte
		dim paintHeight as byte
		dim tile as ubyte
		for i = 0 to enemiesPerScreen(currentScreen) - 1
			if not getSpriteLin(i) then continue for
			
			tile = getSpriteTile(i)
			Draw2x2Sprite(spritesSet(tile), getSpriteCol(i), getSpriteLin(i))
		next i
	end if

	if bulletPositionX <> 0
		Draw1x1Sprite(spritesSet(currentBulletSpriteId), bulletPositionX, bulletPositionY)
	end if

	RenderFrame()
END SUB

sub drawBurst(x as ubyte, y as ubyte)
	Draw2x2Sprite(spritesSet(BURST_SPRITE_ID), x, y)
end sub