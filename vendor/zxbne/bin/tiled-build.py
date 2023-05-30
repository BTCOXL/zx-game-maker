import json
from collections import defaultdict
from pprint import pprint

f = open('output/maps.json')

data = json.load(f)

screenWidth = 16
screenHeight = 8
cellsPerScreen = screenWidth * screenHeight

for layer in data['layers']:
    if layer['type'] == 'tilelayer':
        screensCount = len(layer['data'])//screenWidth//screenHeight
        mapRows = layer['height']//screenHeight
        mapCols = layer['width']//screenWidth
        mapStr = "DIM screens(" + str(screensCount - 1) + ", " + str(screenHeight - 1) + ", " + str(screenWidth - 1) + ") AS UBYTE = {";

        screens = defaultdict(dict)

        for idx, cell in enumerate(layer['data']):
            mapX = idx % layer['width']
            mapY = idx // layer['width']

            screenId = mapX // screenWidth

            if len(screens) == 0 or mapY not in screens[screenId]:
                screens[screenId][mapY] = defaultdict(dict)

            screens[screenId][mapY][mapX % screenWidth] = cell

        for screen in screens:
            mapStr += '{'
            for row in screens[screen]:
                mapStr += '{'
                for cell in screens[screen][row]:
                    mapStr += str(screens[screen][row][cell]) + ","
                mapStr = mapStr[:-1]
                mapStr += "},"
            mapStr = mapStr[:-1]
            mapStr += "},"
        mapStr = mapStr[:-1]
        mapStr += "}"
            


with open("output/maps.bas", "w") as text_file:
    print(mapStr, file=text_file)

# Construct enemies

tileHeight = 16
tileWidth = 16

enemies = {}

for layer in data['layers']:
    if layer['type'] == 'objectgroup':
        for object in layer['objects']:
            if object['type'] == 'enemy':
                enemies[str(object['id'])] = {
                    'name': object['name'],
                    'screenId': str((object['x'] // tileWidth) // screenWidth),
                    'linIni': str(object['y'] // tileHeight % screenHeight * 16),
                    'colIni': str(object['x'] // tileWidth % screenWidth * 2),
                    'tile': str(object['properties'][1]['value']),
                    'endObject': object['properties'][0]['value']
                }
for layer in data['layers']:
    if layer['type'] == 'objectgroup':
        for object in layer['objects']:
            if object['type'] == 'path':
                enemies[str(object['properties'][0]['value'])]['linEnd'] = str(object['y'] // tileHeight % screenHeight * 16)
                enemies[str(object['properties'][0]['value'])]['colEnd'] = str(object['x'] // tileWidth % screenWidth * 2)

screenEnemies = defaultdict(dict)

for enemyId in enemies:
    enemy = enemies[enemyId]
    if len(screenEnemies[enemy['screenId']]) == 0:
        screenEnemies[enemy['screenId']] = []
    screenEnemies[enemy['screenId']].append(enemy)

enemStr = "DIM enemies(" + str(len(screenEnemies)) + ",2,9) as ubyte = {"

enemStr += '{{0, 0, 0, 0, 0, 0, 0, 0, 0, 1},{0, 0, 0, 0, 0, 0, 0, 0, 0, 1},{0, 0, 0, 0, 0, 0, 0, 0, 0, 1}},'

for screenId in screenEnemies:
    enemStr += "{"
    screen = screenEnemies[screenId]
    for i in range(3):
        if i <= len(screen) - 1:
            enemy = screen[i]
            if (enemy['colIni'] < enemy['colEnd']):
                right = '1'
            else:
                right = '0'
            enemStr += '{' + enemy['tile'] + ', ' + enemy['linIni'] + ', ' + enemy['colIni'] + ', ' + enemy['linEnd'] + ', ' + enemy['colEnd'] + ', ' + right + ', ' + enemy['linIni'] + ', ' + enemy['colIni'] + ', 1, ' + str(i + 1) + '},'
        else:
            enemStr += '{0, 0, 0, 0, 0, 0, 0, 0, 0, ' + str(i + 1) + '},'
    enemStr = enemStr[:-1]
    enemStr += "},"
enemStr = enemStr[:-1]
enemStr += "}"

with open("output/enemies.bas", "w") as text_file:
    print(enemStr, file=text_file)