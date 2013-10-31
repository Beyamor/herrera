define ['core/util', 'game/consts', 'game/room-data'], (util, consts, definitions) ->
	ns = {}

	random = util.random

	TILE_WIDTH	= TILE_HEIGHT	= consts.TILE_WIDTH
	ROOM_WIDTH	= ROOM_HEIGHT	= consts.ROOM_WIDTH

	
	transformedXY = (x, y, transformation) ->
		origX = x
		origY = y
		if transformation.rotation is 90
			[x, y] = [ROOM_HEIGHT - 1- y, x]

		else if transformation.rotation is 180
			[x, y] = [ROOM_WIDTH - 1 - x, ROOM_HEIGHT - 1 - y]

		else if transformation.rotation is 270
			[x, y] = [y, ROOM_WIDTH - 1 - x]

		if transformation.mirror is "vertical"
			[x, y] = [x, ROOM_HEIGHT - 1 - y]

		else if transformation.mirror is "horizontal"
			[x, y] = [ROOM_WIDTH - 1 - x, y]

		return [x, y]

	class ns.Room
		constructor: (@xIndex, @yIndex) ->
			@tiles = util.array2d ROOM_WIDTH, ROOM_HEIGHT

	class ns.RegularRoom extends ns.Room
		constructor: (xIndex, yIndex) ->
			super xIndex, yIndex
			@exitDirections = []

		addEntrance: (direction) ->
			@entranceDirection = direction

		addExit: (direction) ->
			@exitDirections.push direction

		finalize: ->
			possibilities = []
			for room in definitions.rooms
				for orientation in room.orientations
					continue unless orientation.entrances[@entranceDirection].length isnt 0

					meetsAllExits = true
					for exitDirection in @exitDirections
						meetsAllExits and= (orientation.exits[exitDirection].length isnt 0)

					continue unless meetsAllExits
					possibilities.push {
						definition: util.copy room.definition
						orientation: util.copy orientation
						slices: util.copy room.slices
					}

			throw new Error("no room possibilities (entrance is #{@entranceDirection})") unless possibilities.length isnt 0
			choice = @translate @applySkips random.any possibilities

			tiles = @realizeOrientation choice.definition, choice.orientation
			@tiles.each (i, j) => @tiles[i][j] = tiles[i][j]

		applySkips: (choice) ->
			definitionWithSkips = util.array2d ROOM_WIDTH, ROOM_HEIGHT

			skipRows	= (row for row in choice.slices.rows when random.coinFlip())
			skipColumns	= (column for column in choice.slices.columns when random.coinFlip())

			defI = tileI = 0
			while defI < ROOM_WIDTH

				unless skipColumns.contains defI
					defJ = tileJ = 0
					while defJ < ROOM_HEIGHT
						unless skipRows.contains defJ
							definitionWithSkips[tileI][tileJ] = choice.definition[defI][defJ]
							++tileJ
						++defJ
					++tileI
				++defI

			for property in ["entrances", "exits"]
				for direction in util.DIRECTIONS
					points = choice.orientation[property][direction]
					for index in [0...points.length]
						[origX, origY] = points[index]
						shiftedX = origX
						shiftedY = origY

						for column in skipColumns
							if column <= origX
								shiftedX -= 1
							else
								break

						for row in skipRows
							if row <= origY
								shiftedY -= 1
							else
								break

						points[index] = [shiftedX, shiftedY]

			choice.definition = definitionWithSkips
			return choice

		translate: (choice) ->
			translatedDefinition = util.array2d ROOM_WIDTH, ROOM_HEIGHT

			xTranslations = [0]
			yTranslations = [0]

			isFree = (i, j) ->
				tile = choice.definition[i][j]
				return (not tile) or (tile is " ")

			free = true
			for i in [0...ROOM_WIDTH]
				for j in [0...ROOM_HEIGHT]
					unless isFree i, j
						free = false
						break
				if free
					xTranslations.push(-1 - i)
				else
					break

			free = true
			for i in [ROOM_WIDTH-1...0]
				for j in [0...ROOM_HEIGHT]
					unless isFree i, j
						free = false
						break
				if free
					xTranslations.push(ROOM_WIDTH - i)
				else
					break
			free = true
			for j in [0...ROOM_HEIGHT]
				for i in [0...ROOM_WIDTH]
					unless isFree i, j
						free = false
						break
				if free
					yTranslations.push(-1 - j)
				else
					break

			free = true
			for j in [ROOM_HEIGHT-1...0]
				for i in [0...ROOM_WIDTH]
					unless isFree i, j
						free = false
						break
				if free
					yTranslations.push(ROOM_HEIGHT - j)
				else
					break

			xTranslation = random.any xTranslations
			yTranslation = random.any yTranslations

			for i in [0...ROOM_WIDTH]
				for j in [0...ROOM_HEIGHT]
					translatedI = i + xTranslation
					translatedJ = j + yTranslation

					continue if translatedI < 0 or translatedI >= ROOM_WIDTH or
							translatedJ < 0 or translatedI >= ROOM_HEIGHT

					translatedDefinition[translatedI][translatedJ] = choice.definition[i][j]

			for property in ["entrances", "exits"]
				for direction in util.DIRECTIONS
					points = choice.orientation[property][direction]
					for point in choice.orientation[property][direction]
						point[0] += xTranslation
						point[1] += yTranslation

			choice.definition = translatedDefinition
			return choice
			
		realizeOrientation: (definition, orientation) ->
			transformation = orientation.transformation

			previous	= util.copy definition
			result		= util.copy definition

			saveState	= -> previous = util.copy result
			get		= (i, j) -> previous[i][j]
			set		= (i, j, value) -> result[i][j] = value

			# pick an entrance
			[x, y] = random.any orientation.entrances[@entranceDirection]
			set x, y, "."
			[transX, transY] = transformedXY x, y, transformation
			@entrance = {x: transX, y: transY}

			# pick exits
			@exits = {}
			for exitDirection in @exitDirections
				[x, y] = random.any orientation.exits[exitDirection]
				set x, y, "."

				[transX, transY] = transformedXY x, y, transformation
				@exits[exitDirection] = {x: transX, y: transY}

			saveState()

			# close out other entrances/exits
			for x in [0...ROOM_WIDTH]
				for y in [0...ROOM_HEIGHT]
					if get(x, y) is "i" or get(x, y) is "o"
						set x, y, "W"

			saveState()

			# and transform
			for x in [0...ROOM_WIDTH]
				for y in [0...ROOM_HEIGHT]
					[transX, transY] = transformedXY x, y, transformation
					set(transX, transY, get(x, y))

			return result


	class ns.StartRoom extends ns.Room
		constructor: (xIndex, yIndex) ->
			super xIndex, yIndex

			for i in [0...ROOM_WIDTH]
				@tiles[i][0] = "wall"
				@tiles[i][ROOM_HEIGHT-1] = "wall"

			for j in [0...ROOM_HEIGHT]
				@tiles[0][j] = "wall"
				@tiles[ROOM_WIDTH-1][j] = "wall"

			for i in [1...ROOM_WIDTH-1]
				for j in [1...ROOM_HEIGHT-1]
					@tiles[i][j] = "floor"

			@exits = {}

		addExit: (direction) ->
			switch direction
				when "west"
					x = 0
					y = ROOM_HEIGHT/2
				when "east"
					x = ROOM_WIDTH - 1
					y = ROOM_HEIGHT/2
				when "north"
					x = ROOM_WIDTH/2
					y = 0
				when "south"
					x = ROOM_WIDTH/2
					y = ROOM_HEIGHT-1

			@tiles[x][y] = "."
			@exits[direction] = {x: x, y: y}

	return ns
