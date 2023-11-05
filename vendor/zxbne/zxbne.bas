dim currentLife as UBYTE = 100
dim currentKeys as UBYTE = 0
dim currentItems as UBYTE = 0
dim moveScreen as ubyte
dim currentScreen as UBYTE = 0
dim animateEnemies as ubyte = 1

dim framec AS ubyte AT 23672

' #include "nirvana+.bas"
#include "GuSprites.zxbas"
#include "../../output/tiles.bas"

InitGFXLib()

SetTileset(@tileSet)

#include "../../output/sprites.bas"
#include "../../output/maps.bas"
#include "../../output/enemies.bas"

#include "const.bas"
#include "functions.bas"
#include "spritesTileAndPosition.bas"
#include "enemies.bas"
#include "bullet.bas"
#include "draw.bas"
#include "protaMovement.bas"
#include "sound.bas"
#include "music.bas"
#include <zx0.bas>
#include <retrace.bas>

menu:
    INK 7: PAPER 0: BORDER 0: BRIGHT 0: FLASH 0: CLS
    ' stopMusicAndNirvana()
    dzx0Standard(@titleScreen, $4000)
    pauseUntilPressKey()
    currentScreen = INITIAL_SCREEN

playGame:
    INK 7: PAPER 0: BORDER 0: BRIGHT 0: FLASH 0: CLS
    currentScreen = INITIAL_SCREEN
    currentLife = INITIAL_LIFE
    currentKeys = 0
    currentItems = 0
    removeScreenObjectFromBuffer()
    initProta()
    setScreenElements()
    dzx0Standard(@hudScreen, $4000)
    redrawScreen()
    drawSprites()
    do
        waitretrace
        protaMovement()
        moveEnemies()
        moveBullet()
        drawSprites()
        animateAnimatedTiles()
        checkMoveScreen()
        checkRemainLife()
    loop

ending:
    ' stopMusicAndNirvana()
    dzx0Standard(@endingScreen, $4000)
    pause 300
    pauseUntilPressKey()
    go to menu

gameOver:
    ' stopMusicAndNirvana()
    PrintString("GAME OVER", 7, 12, 10)
    pause 300
    pauseUntilPressKey()
    go to menu


sub animateAnimatedTiles()
    if framec bAND %10
        return
    end if
    for i=0 to 2:
        if screenAnimatedTiles(currentScreen, i, 0) <> 0
            dim tile as ubyte = screenAnimatedTiles(currentScreen, i, 0) + screenAnimatedTiles(currentScreen, i, 3) + 1
            SetTileChecked(tile, attrSet(tile), screenAnimatedTiles(currentScreen, i, 1), screenAnimatedTiles(currentScreen, i, 2))
            let screenAnimatedTiles(currentScreen, i, 3) = not screenAnimatedTiles(currentScreen, i, 3)
        end if
    next i
end sub

sub stopMusicAndNirvana()
    musicStop()
    INK 7: PAPER 0: BORDER 0: BRIGHT 0: FLASH 0: CLS
end sub

sub checkRemainLife()
    if currentLife = 0
        ' enemiesDraw(1)
        go to gameOver
    end if
end sub

sub checkMoveScreen()
    if moveScreen <> 0
        moveToScreen(moveScreen)
        moveScreen = 0
    end if
end sub

' btiles:
'     asm
'         incbin "assets/tiles.btile"
'     end asm

titleScreen:
    asm
        incbin "output/title.png.scr.zx0"
    end asm

hudScreen:
    asm
        incbin "output/hud.png.scr.zx0"
    end asm

endingScreen:
    asm
        incbin "output/ending.png.scr.zx0"
    end asm

sub debugA(value as UBYTE)
    PRINT AT 18, 10; "----"
    PRINT AT 18, 10; value
end sub

sub debugB(value as UBYTE)
    PRINT AT 18, 15; "  "
    PRINT AT 18, 15; value
end sub

sub debugC(value as UBYTE)
    PRINT AT 18, 20; "  "
    PRINT AT 18, 20; value
end sub

sub debugD(value as UBYTE)
    PRINT AT 18, 25; "  "
    PRINT AT 18, 25; value
end sub