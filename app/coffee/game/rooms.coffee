define ['core/util', 'game/consts', 'game/room-data', 'game/room-features'], (util, consts, definitions, features) ->
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
			@tiles		= util.array2d ROOM_WIDTH, ROOM_HEIGHT
			@xOffset	= @xIndex * (ROOM_WIDTH + 1) * TILE_WIDTH # +1 for the spaces between rooms
			@yOffset	= @yIndex * (ROOM_HEIGHT + 1) * TILE_HEIGHT

		realizeTiles: (reifier) ->
			tiles = []
			@tiles.each (i, j, type) =>
				x = @xOffset + i * TILE_WIDTH
				y = @yOffset + j * TILE_HEIGHT

				tile = reifier.reifyWallOrFloor x, y, type
				tiles.push(tile) if tile?

			return tiles

		realize: (reifier) ->
			return @realizeTiles(reifier)
			
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
			@addFeatures()

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

		addFeatures: ->
			areas = []
			@tiles.each (x, y, tile) =>
				return unless tile is "."

				# sooo many repeated checks
				for width in [0...ROOM_HEIGHT] when x + width < ROOM_WIDTH
					do (width) =>
						for height in [0...ROOM_WIDTH] when y + height < ROOM_HEIGHT
							do (height) =>
								tiles	= []

								clear	= true
								for i in [x...x+width]
									for j in [y...y+height]
										clear and= @tiles[i][j] is "."
										break unless clear
										tiles.push [i, j]
									break unless clear
								return unless clear

								area = {
									set: (i, j, value) =>
										@tiles[x + i][y + j] = value
									width: width
									height: height
									tiles: tiles
									hasTile: ([checkX, checkY]) ->
										for [tileX, tileY] in @tiles
											return true if tileX is checkX and
													tileY is checkY
										return false
								}

								if features.canFill area
									areas.push area

			while areas.length > 0
				someArea = random.any areas

				features.fill someArea

				for tile in someArea.tiles
					areas = (area for area in areas when not area.hasTile tile)

		realize: (reifier, {numberOfEnemies: numberOfEnemies}) ->
			candidates = []
			@tiles.each (tileX, tileY, tile) =>
				if tile is "."
					candidates.push {x: tileX + TILE_WIDTH/2, y: tileY + TILE_HEIGHT/2}

			enemies = []
			while enemies.length <  numberOfEnemies and candidates.length > 0
				candidate = random.any candidates
				candidates.remove candidate

				enemies.push reifier.reifyEnemy candidate.x, candidate.y


			return super(reifier).concat enemies

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

	class ns.EndRoom extends ns.Room
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

		entities: (reifier) ->
			super(reifier).concat [
				type: "portal"
				pos:
					x: Math.floor(ROOM_WIDTH/2)
					y: Math.floor(ROOM_HEIGHT/2)
			]

	class ns.SuperRoomSection extends ns.Room
		constructor: (xIndex, yIndex) ->
			super xIndex, yIndex
			@exits = {}

			@tiles[Math.floor(ROOM_WIDTH/2)][Math.floor(ROOM_HEIGHT/2)] = "."

		anyBorderPoint: (direction) ->
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

		addEntrance: (direction) ->
			@entrance = @anyBorderPoint direction

		addExit: (direction) ->
			@exits[direction] = @anyBorderPoint direction

		finalize: ->
			@superRoom.finalize()

		realize: (args...) ->
			@superRoom.realize.apply(@superRoom, args)

	superRoomColors = ["red", "green", "blue", "yellow", "purple"]
	superRoomColorIndex = -1
	nextSuperRoomColor = ->
		++superRoomColorIndex
		return superRoomColors[(superRoomColorIndex + 1) % superRoomColors.length]

	class ns.SuperRoom
		@MIN_ROOM_DIM: 6
		@MAX_ROOM_DIM: 16
		@MIN_ROOM_RATIO: 0.5

		constructor: (@sections) ->
			section.superRoom = this for section in @sections
			@color = nextSuperRoomColor()

		initialize: (x, y) ->
			cell		= @cells[x][y]
			cell.isActive	= true
			cell.weight	= 4

		initializeCells: ->
			for section in @sections
				xOffset = (section.xIndex - @minRoomX) * (ROOM_WIDTH + 1)
				yOffset = (section.yIndex - @minRoomY) * (ROOM_HEIGHT + 1)

				for i in [0...ROOM_WIDTH]
					for j in [0...ROOM_HEIGHT]
						@initialize i + xOffset, j + yOffset

			@occupationGrid.each (gridX, gridY, isOccupied) =>
				return unless isOccupied

				# check for a neighbour to the right
				if gridX < @widthInRooms - 1 and @occupationGrid[gridX+1][gridY]
					xOffset	= (gridX + 1) * (ROOM_WIDTH + 1) - 1
					yOffset	= gridY * (ROOM_HEIGHT + 1)

					for j in [0...ROOM_HEIGHT]
						@initialize xOffset, j + yOffset

				# check for a neighbour below
				if gridY < @heightInRooms - 1 and @occupationGrid[gridX][gridY+1]
					xOffset	= gridX * (ROOM_WIDTH + 1)
					yOffset	= (gridY + 1) * (ROOM_HEIGHT + 1) - 1

					for i in [0...ROOM_WIDTH]
						@initialize xOffset + i, yOffset

		establishPossibleRooms: ->
			@possibleRooms = []

			@cells.each (left, top, cell) =>
				return unless cell.isActive

				# some magic 2s to ensure we can always close a path
				# (a path requires 1 for floors, 1 for walls)
				return unless left - 2 >= 0 and top - 2 >= 0

				for width in [ns.SuperRoom.MIN_ROOM_DIM..ns.SuperRoom.MAX_ROOM_DIM] when\
												left + width + 2 <= @widthInCells
					for height in [ns.SuperRoom.MIN_ROOM_DIM..ns.SuperRoom.MAX_ROOM_DIM] when\
												top + height + 2 <= @heightInCells

						continue if (width / height) < ns.SuperRoom.MIN_ROOM_RATIO
						continue if (height / width) < ns.SuperRoom.MIN_ROOM_RATIO

						isValid = true
						for i in [-2...width + 2]
							for j in [-2...height + 2]
								unless @cells[left + i][top + j].isActive
									isValid = false
									break
							break unless isValid
						continue unless isValid

						@possibleRooms.push
							left:	left
							top:	top
							right:	left + width - 1
							bottom:	top + height - 1

		makeRooms: ->
			area			= @widthInRooms * @heightInRooms
			numberOfRooms		= 0
			@rooms			= []
			@roomCenters		= []

			while @possibleRooms.length > 0
				room		= random.any @possibleRooms
				@possibleRooms	= (r for r in @possibleRooms when not util.aabbsIntersect r, room)
				@rooms.push room
				@roomCenters.push @centerCell room

				for i in [room.left..room.right]
					for j in [room.top..room.bottom]
						isWall	= i is room.left or i is room.right or
								j is room.top or j is room.bottom

						if isWall
							@setAsWall i, j
						else
							@setAsFloor i, j

				++numberOfRooms

		setAsWall: (x, y) ->
			throw new Error "Cell not active" unless @cells[x][y].isActive
			cell		= @cells[x][y]
			cell.type	= "wall"
			cell.weight	= 20

		setAsFloor: (x, y) ->
			throw new Error "Cell not active" unless @cells[x][y].isActive
			cell		= @cells[x][y]
			cell.type	= "floor"
			cell.weight	= 0

		neighbouringCells: ({x: x, y: y}, opts) ->
			cells = []

			left	= x > 0
			right	= x < @widthInCells - 1
			top	= y > 0
			bottom	= y < @heightInCells - 1

			cells.push @cells[x-1][y] if left
			cells.push @cells[x+1][y] if right
			cells.push @cells[x][y-1] if top
			cells.push @cells[x][y+1] if bottom

			if opts and opts.includeDiagonals
				cells.push @cells[x-1][y-1] if left and top
				cells.push @cells[x-1][y+1] if left and bottom
				cells.push @cells[x+1][y-1] if right and top
				cells.push @cells[x+1][y+1] if right and bottom

			if opts and opts.excludeBorders
				previousLength = cells.length
				cells = _.filter cells, (cell) =>
					return false if	cell.x - 1 < 0 or cell.x + 1 >= @widthInCells or
							cell.y - 1 < 0 or cell.y + 1 >= @heightInCells

					return false unless	@cells[cell.x - 1][cell.y].isActive and
								@cells[cell.x + 1][cell.y].isActive and
								@cells[cell.x][cell.y - 1].isActive and
								@cells[cell.x][cell.y + 1].isActive

					return true

			return cells

		makePath: (startingCell, endingCell) ->
			initialNode	= {cell: startingCell}
			closedList	= [initialNode]
			openList	= []

			g = (node) =>
				weight = node.cell.weight
				if node.parent?
					weight += g(node.parent)
				return weight

			h = (node) =>
				dx	= node.cell.x - endingCell.x
				dy	= node.cell.y - endingCell.y

				return dx*dx + dy*dy

			addAdjacentNodes = (parent) =>
				for neighbouringCell in @neighbouringCells parent.cell, {excludeBorders: true}
					alreadyInClosedList	= false
					alreadyInOpenList	= false
					existingNode		= null

					for node in openList
						if node.cell is neighbouringCell
							alreadyInOpenList	= true
							existingNode		= node
							break

					unless alreadyInOpenList
						for node in closedList
							if node.cell is neighbouringCell
								alreadyInClosedList	= true
								existingNode		= node
								break

					if alreadyInOpenList
						if existingNode.parent and g(parent) < g(existingNode.parent)
							existingNode.parent = parent
					else if not alreadyInClosedList
						unless neighbouringCell.isActive
							throw new Error "Whoa, adding inactive cell to the open list"
						openList.push
							cell:	neighbouringCell
							parent:	parent

			addAdjacentNodes initialNode

			until lastNode?
				if openList.length is 0
					throw Error "No nodes in open list"

				nextNode	= null
				minF		= Infinity
				for node in openList
					throw Error "no node" unless node?
					f = g(node) + h(node)
					if f < minF
						minF		= f
						nextNode	= node

				if nextNode.cell is endingCell
					lastNode = nextNode
				else
					openList.remove nextNode
					closedList.push nextNode
					addAdjacentNodes nextNode

			path = []
			addToPath = (node) ->
				return unless node?

				path.unshift node.cell
				addToPath node.parent
			addToPath lastNode

			for cell in path
				@setAsFloor cell.x, cell.y

			@paths.push path

		centerCell: (room) ->
			cellX	= Math.floor((room.left + room.right) / 2)
			cellY	= Math.floor((room.top + room.bottom) / 2)
			return @cells[cellX][cellY]

		connectRooms: ->
			return unless @rooms.length > 1
			for roomIndex in [0...@rooms.length]
				currentRoom	= @rooms[roomIndex]
				nextRoom	= @rooms[(roomIndex + 1) % @rooms.length]

				@makePath @centerCell(currentRoom), @centerCell(nextRoom)

			numberOfAdditionalPaths		= 0
			maxNumberOfAdditionalPaths	= random.intInRange 3
			while numberOfAdditionalPaths < maxNumberOfAdditionalPaths
				first	= random.intInRange @rooms.length
				second	= random.intInRange @rooms.length
				until second isnt first
					second	= random.intInRange @rooms.length

				@makePath @centerCell(@rooms[first]), @centerCell(@rooms[second])
				++numberOfAdditionalPaths

		closestRoomCenter: ({x: x, y: y}) ->
			smallestDistance = Infinity

			for center in @roomCenters
				dx	= x - center.x
				dy	= y - center.y
				d	= dx*dx + dy*dy

				if d < smallestDistance
					smallestDistance	= d
					closestCenter		= center

			return closestCenter

		addBorderConnections: ->
			for section in @sections
				xOffset	= (section.xIndex - @minRoomX) * (ROOM_WIDTH + 1)
				yOffset	= (section.yIndex - @minRoomY) * (ROOM_HEIGHT + 1)

				entrance = section.entrance
				if section.entrance?
					entranceCell	= @cells[entrance.x + xOffset][entrance.y + yOffset]
					center		= @closestRoomCenter entranceCell
					@makePath entranceCell, center

				for direction, exit of section.exits
					exitCell	= @cells[exit.x + xOffset][exit.y + yOffset]
					center		= @closestRoomCenter exitCell
					@makePath exitCell, center

		closePaths: ->
			for path in @paths
				for cell in path
					for neighbour in @neighbouringCells cell, {includeDiagonals: true}
						if neighbour.isActive and not neighbour.type?
							@setAsWall neighbour.x, neighbour.y

		copyTilesToSections: ->
			for section in @sections
				xOffset = (section.xIndex - @minRoomX) * (ROOM_WIDTH + 1)
				yOffset = (section.yIndex - @minRoomY) * (ROOM_HEIGHT + 1)

				for i in [0...ROOM_WIDTH]
					for j in [0...ROOM_HEIGHT]
						section.tiles[i][j] = @cells[i + xOffset][j + yOffset].type

		finalize: ->
			return if @finalized
			@finalized = true

			@minRoomX = @minRoomY = Infinity
			@maxRoomX = @maxRoomY = -Infinity

			for section in @sections
				@minRoomX = section.xIndex if section.xIndex < @minRoomX
				@minRoomY = section.yIndex if section.yIndex < @minRoomY
				@maxRoomX = section.xIndex if section.xIndex > @maxRoomX
				@maxRoomY = section.yIndex if section.yIndex > @maxRoomY

			@widthInRooms	= @maxRoomX - @minRoomX + 1
			@heightInRooms	= @maxRoomY - @minRoomY + 1
			@widthInCells	= @widthInRooms * (ROOM_WIDTH + 1) - 1
			@heightInCells	= @heightInRooms * (ROOM_HEIGHT + 1) - 1

			@cells		= util.array2d @widthInCells, @heightInCells, (i, j) =>
											isActive: false
											x: i
											y: j
			@occupationGrid	= util.array2d @widthInRooms, @heightInRooms, => false
			@paths		= []

			for section in @sections
				@occupationGrid[section.xIndex - @minRoomX][section.yIndex - @minRoomY] = true
				
			@initializeCells()
			@establishPossibleRooms()
			@makeRooms()
			@connectRooms()
			@addBorderConnections()
			@closePaths()
			@copyTilesToSections()

		realize: (reifier) ->
			return [] if @realized
			@realized = true

			xOffset = @minRoomX * (ROOM_WIDTH + 1) * TILE_WIDTH
			yOffset = @minRoomY * (ROOM_HEIGHT + 1) * TILE_HEIGHT

			es = []
			@cells.each (i, j, cell) =>
				return unless cell.isActive

				x = xOffset + i * TILE_WIDTH
				y = yOffset + j * TILE_HEIGHT

				tile = reifier.reifyWallOrFloor x, y, cell.type, @color
				es.push tile if tile

			return es

	return ns
