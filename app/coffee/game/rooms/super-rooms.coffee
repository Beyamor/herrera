define ['core/util', 'game/consts'], (util, consts) ->
	ns = {}

	random = util.random

	TILE_WIDTH	= TILE_HEIGHT	= consts.TILE_WIDTH
	ROOM_WIDTH	= ROOM_HEIGHT	= consts.ROOM_WIDTH

	superRoomColors = ["red", "green", "blue", "yellow", "purple"]
	superRoomColorIndex = -1
	nextSuperRoomColor = ->
		++superRoomColorIndex
		return superRoomColors[(superRoomColorIndex + 1) % superRoomColors.length]

	class ns.OrganicLayout
		@MIN_ROOM_DIM: 5
		@MAX_ROOM_DIM: 14
		@MIN_ROOM_RATIO: 0.7

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

				for width in [ns.OrganicLayout.MIN_ROOM_DIM..ns.OrganicLayout.MAX_ROOM_DIM] when\
						left + width + 2 <= @widthInCells
					for height in [ns.OrganicLayout.MIN_ROOM_DIM..ns.OrganicLayout.MAX_ROOM_DIM] when\
							top + height + 2 <= @heightInCells

						continue if (width / height) < ns.OrganicLayout.MIN_ROOM_RATIO
						continue if (height / width) < ns.OrganicLayout.MIN_ROOM_RATIO

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
							area:	width * height

		makeRooms: ->
			area			= @widthInRooms * @heightInRooms
			numberOfRooms		= 0
			@rooms			= []
			@roomCenters		= []
			@floorCells		= []

			while @possibleRooms.length > 0
				weightedPossibleRooms = []
				for room in @possibleRooms
					for i in [0...room.area]
						weightedPossibleRooms.push room
				room		= random.any weightedPossibleRooms
				@possibleRooms	= (r for r in @possibleRooms when not util.aabbsIntersect r, room)
				@rooms.push room
				@roomCenters.push @centerCell room

				for i in [room.left..room.right]
					for j in [room.top..room.bottom]
						isWall	= i is room.left or i is room.right or
								j is room.top or j is room.bottom

						throw new Error "Cell #{i}, #{j} already set" if @cells[i][j].type?

						if isWall
							@setAsWall i, j, includePossibleGaps: true
						else
							@setAsFloor i, j
							@floorCells.push @cells[i][j]

				++numberOfRooms

		setAsWall: (x, y, opts) ->
			throw new Error "Cell not active" unless @cells[x][y].isActive
			cell		= @cells[x][y]
			cell.type	= "wall"
			cell.weight	= 10

			if opts and opts.includePossibleGaps and random.chance(30)
				cell.weight = 4

		setAsFloor: (x, y) ->
			throw new Error "Cell not active" unless @cells[x][y].isActive
			cell		= @cells[x][y]
			cell.type	= "floor"
			cell.weight	= 1

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

				return Math.sqrt(dx*dx + dy*dy)

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
					closestCenter	= @closestRoomCenter entranceCell

					if section.entranceDirection is "north" or section.entranceDirection is "south"
						section.entrance.x = util.clamp closestCenter.x - xOffset, 1, ROOM_WIDTH - 2
					else
						section.entrance.y = util.clamp closestCenter.y - yOffset, 1, ROOM_HEIGHT - 2
					entranceCell = @cells[entrance.x + xOffset][entrance.y + yOffset]

					@makePath entranceCell, closestCenter

				for direction, exit of section.exits
					exitCell	= @cells[exit.x + xOffset][exit.y + yOffset]
					closestCenter	= @closestRoomCenter exitCell

					if direction is "north" or direction is "south"
						exit.x = util.clamp closestCenter.x - xOffset, 1, ROOM_WIDTH - 2
					else
						exit.y = util.clamp closestCenter.y - yOffset, 1, ROOM_HEIGHT - 2
					exitCell = @cells[exit.x + xOffset][exit.y + yOffset]

					@makePath exitCell, closestCenter

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

		realize: (reifier, {numberOfEnemies: numberOfEnemies}) ->
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

			for i in [0...numberOfEnemies * @sections.length]
				floor	= random.any @floorCells
				x	= xOffset + floor.x * TILE_WIDTH + TILE_WIDTH/2
				y	= yOffset + floor.y * TILE_HEIGHT + TILE_HEIGHT/2

				es.push reifier.reifyEnemy x, y
				@floorCells.remove floor

			return es
	return ns
