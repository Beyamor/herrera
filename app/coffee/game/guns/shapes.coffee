define ['core/util'], (util) ->
	ns = {}

	random = util.random

	class ns.Pin
		constructor: (@model) ->
			@vertices = []

		moveTo: (x, y) ->
			for vertex in @vertices
				unless vertex.isBeingMoved
					vertex.isBeingMoved = true
					vertex.moveTo x, y
					vertex.applyVertexConstraints()
					vertex.isBeingMoved = false


		add: (vertex) ->
			if @vertices.length > 0
				vertex.moveTo @vertices[0].x, @vertices[0].y

			@vertices.push vertex
			vertex.pin = this

		remove: (vertex) ->
			vertex.pin = null
			@vertices.remove vertex

			if @vertices.length <= 1
				for vertex in @vertices
					vertex.pin = null

				@vertices = []
				@model.get('pins').remove this

		contains: (vertex) ->
			@vertices.contains vertex

	class Vertex
		constructor: (@x, @y, @name, @wiggle) ->
			@wiggle or= {
				north:	0
				east:	0
				south:	0
				west:	0
			}

		moveTo: (@x, @y) ->
			if @pin and not @isBeingMoved
				@pin.moveTo @x, @y

		pinTo: (other) ->
			return if other is this or other.shape is @shape

			if @pin
				@pin.add other
			else if other.pin
				other.pin.add this
			else
				@model.createPin other, this

		unpin: ->
			@pin.remove this if @pin

		applyVertexConstraints: ->
			return if @isBeingConstrained
			return unless @vertexConstraints

			for constraint in @vertexConstraints()
				x	= constraint.x or constraint.vertex.x
				y	= constraint.y or constraint.vertex.y
				vertex	= constraint.vertex

				vertex.isBeingConstrained = true
				vertex.moveTo x, y
				vertex.isBeingConstrained = false

		savePosition: ->
			@savedX = @x
			@savedY = @y

		restorePosition: ->
			@x = @savedX
			@y = @savedY

		toJSON: ->
			# ugh surely there's a better way
			x:	@x
			y:	@y
			name:	@name
			wiggle:	@wiggle

	vertexList = (vertices) ->
		(new Vertex v.x, v.y, v.name, v.wiggle for v in vertices)

	class Shape
		constructor: (model, args) ->
			@shape		= args.shape
			@vertices	= args.vertices
			@painted	= if args.painted? then args.painted else true

			for vertex in @vertices
				vertex.model	= model
				vertex.shape	= this

			@invisibleEdges	= []
			@painted	= true

		edgeIsInvisible: (v1, v2) ->
			indexOfV1 = @vertices.indexOf v1
			indexOfV2 = @vertices.indexOf v2

			for edge in @invisibleEdges
				if (edge[0] is indexOfV1 and edge[1] is indexOfV2) or (edge[1] is indexOfV2 and edge[0] is indexOfV1)
					return true
			return false

		toggleEdgeVisibility: ([v1, v2]) ->
			v1Index	= @vertices.indexOf v1
			v2Index = @vertices.indexOf v2

			for edge in @invisibleEdges
				if (edge[0] is v1Index and edge[1] is v2Index) or
					(edge[1] is v1Index and edge[0] is v2Index)
						invisibleEdge = edge
						break

			if invisibleEdge?
				@invisibleEdges.remove invisibleEdge
			else
				@invisibleEdges.push [v1Index, v2Index]

		saveVertices: ->
			for vertex in @vertices
				vertex.savePosition()

		restoreVertices: ->
			for vertex in @vertices
				vertex.restorePosition()

		toJSON: ->
			vertices:	(vertex.toJSON() for vertex in @vertices)
			invisibleEdges:	@invisibleEdges
			painted:	@painted
			shape:		@shape

		renderData: ->
			visibleEdges = []
			for vertexIndex in [0...@vertices.length]
				v1 = @vertices[vertexIndex]
				v2 = @vertices[(vertexIndex+1) % @vertices.length]

				unless @edgeIsInvisible v1, v2
					visibleEdges.push [v1.toJSON(), v2.toJSON()]

			return {
				vertices: (vertex.toJSON() for vertex in @vertices)
				visibleEdges: visibleEdges
				painted: @painted
			}

		wiggle: ->
			for vertex in @vertices
				dx = random.inRange -vertex.wiggle.west, vertex.wiggle.east
				dy = random.inRange -vertex.wiggle.north, vertex.wiggle.south

				vertex.moveTo vertex.x + dx, vertex.y + dy
				vertex.applyVertexConstraints()

	class ns.Triangle extends Shape
		constructor: (model, args) ->
			args or= {}

			super model,
				shape: "triangle"
				vertices: vertexList(
					args.vertices or [
						{x: 0,		y: -5}
						{x: 4.33,	y: 2.5}
						{x: -4.33,	y: 2.5}
					]
				)

	class ns.Quad extends Shape
		constructor: (model, args) ->
			args or= {}

			super model,
				shape: "quad"
				vertices: vertexList(
					args.vertices or [
						{x: -5,	y: -5}
						{x: 5,	y: -5}
						{x: 5,	y: 5}
						{x: -5,	y: 5}
					]
				)

	class ns.Rectangle extends Shape
		constructor: (model, args) ->
			args or= {}

			[topLeft, topRight, bottomRight, bottomLeft] =
				vertexList(
					args.vertices or [
						{x: -5,	y: -5}
						{x: 5,	y: -5}
						{x: 5,	y: 5}
						{x: -5,	y: 5}
					]
				)

			topLeft.vertexConstraints = -> [
				{vertex: topRight, y: @y}
				{vertex: bottomLeft, x: @x}
			]

			topRight.vertexConstraints = -> [
				{vertex: topLeft, y: @y}
				{vertex: bottomRight, x: @x}
			]

			bottomRight.vertexConstraints = -> [
				{vertex: topRight, x: @x}
				{vertex: bottomLeft, y: @y}
			]

			bottomLeft.vertexConstraints = -> [
				{vertex: bottomRight, y: @y}
				{vertex: topLeft, x: @x}
			]

			super model,
				shape:		"rectangle"
				vertices:	[topLeft, topRight, bottomRight, bottomLeft]

	return ns
