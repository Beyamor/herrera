define ['core/util', 'game/consts'], (util, consts) ->
	ns = {}

	random = util.random

	TILE_WIDTH	= TILE_HEIGHT	= consts.TILE_WIDTH
	ROOM_WIDTH	= ROOM_HEIGHT	= consts.ROOM_WIDTH
	realizeTiles = (room, reifier) ->
		tiles = []
		room.tiles.each (i, j, type) =>
			x = room.xOffset + i * TILE_WIDTH
			y = room.yOffset + j * TILE_HEIGHT

			tile = reifier.reifyWallOrFloor x, y, type
			tiles.push(tile) if tile?

		return tiles

	definitions = {}
	ns.define = (type, methods) ->
		definitions[type] = {}
		for methodName, methodBody of methods
			do (methodName, methodBody) ->
				definitions[type][methodName] = methodBody

	callDefinition = (room, methodName, args...) ->
		if definitions[room.type]? and definitions[room.type][methodName]?
			method = definitions[room.type][methodName]
			method.apply room, args

	ns.create = (type, xIndex, yIndex) ->
		room = {
			type:		type
			xIndex:		xIndex
			yIndex:		yIndex
			tiles:		util.array2d ROOM_WIDTH, ROOM_HEIGHT
			exits:		{}
			xOffset:	xIndex * (ROOM_WIDTH + 1) * TILE_WIDTH # +1 for the spaces between rooms
			yOffset:	yIndex * (ROOM_HEIGHT + 1) * TILE_HEIGHT
		}

		callDefinition room, 'create'
		return room

	ns.addEntrance = (room, direction) ->
		callDefinition room, 'addEntrance', direction

	ns.addExit = (room, direction)	->
		callDefinition room, 'addExit', direction

	ns.finalize = (room) ->
		callDefinition room, 'finalize'

	ns.realize = (room, reifier, opts) ->
		es = realizeTiles room, reifier
		moreEs = callDefinition room, 'realize', reifier, opts
		if moreEs?
			es = es.concat moreEs
		return es

	ns.define 'start',
		create: ->
			for i in [0...ROOM_WIDTH]
				@tiles[i][0] = "wall"
				@tiles[i][ROOM_HEIGHT-1] = "wall"

			for j in [0...ROOM_HEIGHT]
				@tiles[0][j] = "wall"
				@tiles[ROOM_WIDTH-1][j] = "wall"

			for i in [1...ROOM_WIDTH-1]
				for j in [1...ROOM_HEIGHT-1]
					@tiles[i][j] = "floor"

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

	ns.define "end",
		create: ->
			for i in [0...ROOM_WIDTH]
				@tiles[i][0] = "wall"
				@tiles[i][ROOM_HEIGHT-1] = "wall"

			for j in [0...ROOM_HEIGHT]
				@tiles[0][j] = "wall"
				@tiles[ROOM_WIDTH-1][j] = "wall"

			for i in [1...ROOM_WIDTH-1]
				for j in [1...ROOM_HEIGHT-1]
					@tiles[i][j] = "floor"

		addEntrance: (direction) ->
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
			@entrance = {x: x, y: y}

		realize: (reifier) -> [
			reifier.reifyPortal(
				@xOffset + Math.floor(ROOM_WIDTH/2) * TILE_WIDTH,
				@yOffset + Math.floor(ROOM_HEIGHT/2) * TILE_HEIGHT
			)
		]

	anyBorderPoint = (direction) ->
			switch direction
				when "north"
					x = random.intInRange 1, ROOM_WIDTH - 1
					y = 0

				when "south"
					x = random.intInRange 1, ROOM_WIDTH - 1
					y = ROOM_HEIGHT - 1

				when "east"
					x = ROOM_WIDTH - 1
					y = random.intInRange 1, ROOM_HEIGHT - 1

				when "west"
					x = 0
					y = random.intInRange 1, ROOM_HEIGHT - 1

				else
					throw new Error "Unrecognized direction #{direction}"
			return {x: x, y: y}


	ns.define 'superroom',
		addEntrance: (direction) ->
			@entrance		= anyBorderPoint direction
			@entranceDirection	= direction

		addExit: (direction) ->
			@exits[direction] = anyBorderPoint direction

		finalize: ->
			@superRoom.finalize()

		realize: (args...) ->
			@superRoom.realize.apply(@superRoom, args)

	return ns
