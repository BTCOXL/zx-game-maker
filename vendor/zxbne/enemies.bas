CONST ENEMY_TILE as UBYTE = 0
CONST ENEMY_LIN_INI as UBYTE = 1
CONST ENEMY_COL_INI as UBYTE = 2
CONST ENEMY_LIN_END as UBYTE = 3
CONST ENEMY_COL_END as UBYTE = 4
CONST ENEMY_RIGHT as UBYTE = 5
CONST ENEMY_CURRENT_LIN as UBYTE = 6
CONST ENEMY_CURRENT_COL as UBYTE = 7
CONST ENEMY_ALIVE as UBYTE = 8
CONST ENEMY_SPRITE as UBYTE = 9
CONST OBJECT_TYPE as UBYTE = 10
CONST ENEMY_BURST_CELL as UBYTE = 14
CONST OBJECT_TYPE_EMPTY = 0
CONST OBJECT_TYPE_ENEMY = 1
CONST OBJECT_TYPE_KEY = 2
CONST OBJECT_TYPE_ITEM = 3

function isAnEnemy(lin as UBYTE, col as UBYTE) as UBYTE
    for key=0 TO MAX_OBJECTS_PER_SCREEN - 1
        dim isAlive as ubyte = enemies(currentScreen, key, ENEMY_ALIVE)
        dim enemyLin as ubyte = getSpriteLin(key)/2
        dim enemyCol as ubyte = getSpriteCol(key)/2
        if isAlive = 1 and enemyLin = lin and enemyCol = col 
            return key 'enemies(currentScreen, key, ENEMY_SPRITE)
        end if
    next key
	return 10
end function

function isAKey(lin as UBYTE, col as UBYTE) as UBYTE
    if lin = key_lin and col = key_col
        return key_sprite
	else
        return 10
    end if
end function

sub setScreenElements()
    screenObjects = screenObjectsInitial
end sub

sub setEnemies()
    enemies = enemiesInitial
end sub

sub moveEnemies()
    if framec bAND %10
        return
    end if

    if animateEnemies <> 1
        return
    end if

    dim counter as ubyte = 0
    dim frame as ubyte = 0
    for enemyId=0 TO MAX_OBJECTS_PER_SCREEN - 1
        if enemies(currentScreen, enemyId, OBJECT_TYPE) <> OBJECT_TYPE_ENEMY
            continue for
        end if
        if enemies(currentScreen, enemyId, ENEMY_TILE) = 0
            continue for
        end if
        if enemies(currentScreen, enemyId, ENEMY_ALIVE) = 1 'In the screen and still live
            if counter < 8
                dim tile as UBYTE
                dim enemyCol as UBYTE = enemies(currentScreen, enemyId, ENEMY_CURRENT_COL) 
                dim enemyLin as UBYTE = enemies(currentScreen, enemyId, ENEMY_CURRENT_LIN) 

                if enemies(currentScreen, enemyId, ENEMY_RIGHT) = 1 and enemies(currentScreen, enemyId, ENEMY_COL_END) = enemyCol
                    enemies(currentScreen, enemyId, ENEMY_RIGHT) = 0
                elseif enemies(currentScreen, enemyId, ENEMY_RIGHT) <> 1 and enemies(currentScreen, enemyId, ENEMY_COL_INI) = enemyCol
                    enemies(currentScreen, enemyId, ENEMY_RIGHT) = 1
                end if
                    
                if enemies(currentScreen, enemyId, ENEMY_RIGHT) = 1
                    if enemyCol < enemies(currentScreen, enemyId, ENEMY_COL_END)
                        enemies(currentScreen, enemyId, ENEMY_CURRENT_COL) = enemies(currentScreen, enemyId, ENEMY_CURRENT_COL) + 1
                    end if
                    tile = enemies(currentScreen, enemyId, ENEMY_TILE)
                else
                    if enemyCol > enemies(currentScreen, enemyId, ENEMY_COL_INI)
                        enemies(currentScreen, enemyId, ENEMY_CURRENT_COL) = enemies(currentScreen, enemyId, ENEMY_CURRENT_COL) - 1
                    end if
                    tile = enemies(currentScreen, enemyId, ENEMY_TILE) + 2
                end if

                if getSpriteFrame(enemyId) = 0
                    tile = tile + 1
                end if

                saveSprite(enemyId, enemyLin, enemies(currentScreen, enemyId, ENEMY_CURRENT_COL), tile, enemies(currentScreen, enemyId, ENEMY_RIGHT))

                checkProtaCollision(enemyCol, enemyLin, enemies(currentScreen, enemyId, ENEMY_RIGHT))
            end if
            counter = counter + 1
        end if
    next enemyId
end sub

sub checkProtaCollision(enemyCol as ubyte, enemyLin as ubyte, enemyDirection as ubyte)
    protaLin = getSpriteLin(PROTA_SPRITE)
    protaCol = getSpriteCol(PROTA_SPRITE)    

    if protaLin <> enemyLin then return

    if protaCol = enemyCol
        protaTouch(enemyDirection)
        return
    end if

    if protaCol < enemyCol
        if protaCol + 1 = enemyCol
            protaTouch(enemyDirection)
        end if
    else
        if protaCol = enemyCol + 1
            protaTouch(enemyDirection)
        end if
    end if
end sub

sub protaTouch(enemyDirection as ubyte)
    protaBounce(enemyDirection)
    decrementLife()
    damageSound()
end sub

' sub enemiesDraw(delete as ubyte)
'     dim tile as Ubyte = 29
' 	for key=0 TO MAX_OBJECTS_PER_SCREEN - 1
'         if enemies(currentScreen, key, ENEMY_TILE) = 0
'             continue for
'         end if
' 		if enemies(currentScreen, key, ENEMY_ALIVE) = 1 'In the screen and still live
'             if delete = 1
'                 tile = 29
'             else
'                 tile = enemies(currentScreen, key, ENEMY_TILE)
'             end if
'             NIRVANAspriteT(enemies(currentScreen, key, ENEMY_SPRITE), tile, enemies(currentScreen, key, ENEMY_CURRENT_LIN), enemies(currentScreen, key, ENEMY_CURRENT_COL))
' 		end if
' 	next key
' end sub

' sub removeAllObjects()
'     animateEnemies = 0
'     for i = 0 to 5
'         dim col as UBYTE = PEEK SPRITECOL(i)
'         dim lin as UBYTE = PEEK SPRITELIN(i)

'         saveSprite(i, 0, 0, getSpriteTile(i), 0)
'         ' NIRVANAspriteT(i, 29, 0, 0)
'         restoreScr(lin, col)
' 	next i
'     animateEnemies = 1
' end sub
