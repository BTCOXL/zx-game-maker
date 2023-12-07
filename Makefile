BIN_FOLDER=vendor/zxsgm/bin/
PROJECT_NAME=game
DOCKER_VERSION=latest

tiled-export:
	tiled --export-map json assets/maps.tmx output/maps.json

tiled-build:
	python3 ${BIN_FOLDER}tiled-build.py
	cat output/screen*.bin.zx0 > output/map.bin.zx0
	cat output/enemiesInScreen*.bin.zx0 > output/enemies.bin.zx0
	rm -f output/screen*.bin.zx0
	rm -f output/screen*.bin
	rm -f output/enemiesInScreen*.bin.zx0
	rm -f output/enemiesInScreen*.bin

fx-to-bas:
	@if [ -f assets/soundEffects.asm ]; then\
		cat assets/soundEffects.asm | sed "s/	org 60000/sub fastcall BeepFX_Play\(sonido AS UByte\)\nasm/" | sed "s/ld a\,19/\n/" | { cat; echo "end asm"; echo "end sub"; } > output/soundEffects.bas;\
	else\
		cp -f vendor/zxsgm/default/soundEffects.bas output/soundEffects.bas;\
	fi

screens-build:
	python3 ${BIN_FOLDER}fixColors.py assets/screens/title.png assets/screens/title.tmp.png
	python3 ${BIN_FOLDER}png2scr.py assets/screens/title.tmp.png
	java -jar ${BIN_FOLDER}zx0.jar -f assets/screens/title.tmp.png.scr output/title.png.scr.zx0

	python3 ${BIN_FOLDER}fixColors.py assets/screens/ending.png assets/screens/ending.tmp.png
	python3 ${BIN_FOLDER}png2scr.py assets/screens/ending.tmp.png
	java -jar ${BIN_FOLDER}zx0.jar -f assets/screens/ending.tmp.png.scr output/ending.png.scr.zx0

	python3 ${BIN_FOLDER}fixColors.py assets/screens/hud.png assets/screens/hud.tmp.png
	python3 ${BIN_FOLDER}png2scr.py assets/screens/hud.tmp.png
	java -jar ${BIN_FOLDER}zx0.jar -f assets/screens/hud.tmp.png.scr output/hud.png.scr.zx0

	python3 ${BIN_FOLDER}fixColors.py assets/screens/loading.png assets/screens/loading.tmp.png
	python3 ${BIN_FOLDER}png2scr.py assets/screens/loading.tmp.png
	mv assets/screens/loading.tmp.png.scr output/loading.bin

	python3 ${BIN_FOLDER}img2zxbasic/src/img2zxbasic.py -i assets/tiles.png -p assets/paperValues.txt -t tiles > output/tiles.bas
	python3 ${BIN_FOLDER}img2zxbasic/src/img2zxbasic.py -i assets/sprites.png -p assets/paperValues.txt -t sprites > output/sprites.bas

compile:
	python3 ${BIN_FOLDER}zxbasic/zxbc.py -W 500 -taB main.bas
	mv -f main.tap output/${PROJECT_NAME}.tap

build:
	$(MAKE) tiled-build
	$(MAKE) screens-build
	$(MAKE) fx-to-bas
	python3 ${BIN_FOLDER}zxbasic/zxbc.py -H 2048 -S 24576 -O 4 main.bas -o output/main.bin

	wine ${BIN_FOLDER}bas2tap.exe -a10 -s${PROJECT_NAME} ${BIN_FOLDER}loader.bas output/loader.tap
	wine ${BIN_FOLDER}bin2tap.exe -o output/loading.tap -a 16384 output/loading.bin
	wine ${BIN_FOLDER}bin2tap.exe -o output/main.tap -a 24576 output/main.bin

	@if [ -f assets/music/music.tap ]; then\
		cat output/loader.tap output/loading.tap output/main.tap assets/music/music.tap > output/${PROJECT_NAME}.tap;\
	else\
		cat output/loader.tap output/loading.tap output/main.tap > output/${PROJECT_NAME}.tap;\
	fi
	

build-dev:
	$(MAKE) tiled-export
	$(MAKE)	build

docker-build:
	docker build -t rtorralba/zx-game-maker:${DOCKER_VERSION} .

docker-push:
	docker push rtorralba/zx-game-maker:${DOCKER_VERSION}

run:
	fuse --machine=plus2a output/${PROJECT_NAME}.tap