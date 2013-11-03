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
		constructor: (@x, @y) ->

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

	class Shape
		constructor: (model, @vertices...) ->
			for vertex in @vertices
				vertex.model	= model
				vertex.shape	= this

		saveVertices: ->
			for vertex in @vertices
				vertex.savePosition()

		restoreVertices: ->
			for vertex in @vertices
				vertex.restorePosition()

		toJSON: ->
			vertices = []
			for vertex in @vertices
				vertices.push {x: vertex.x, y: vertex.y}
			return {vertices: vertices}

		wiggle: ->
			for vertex in @vertices
				dx = random.inRange -0.5, 0.5
				dy = random.inRange -0.5, 0.5

				vertex.moveTo vertex.x + dx, vertex.y + dy
				vertex.applyVertexConstraints()

	class ns.Triangle extends Shape
		constructor: (model) ->
			super(
				model,
				new Vertex(0, -5),
				new Vertex(4.33, 2.5),
				new Vertex(-4.33, 2.5)
			)


	class ns.Quad extends Shape
		constructor: (model) ->
			super(
				model,
				new Vertex(-5, -5),
				new Vertex(5, -5),
				new Vertex(5, 5),
				new Vertex(-5, 5)
			)

	class ns.Rectangle extends Shape
		constructor: (model) ->
			topLeft		= new Vertex(-5, -5)
			topRight	= new Vertex(5, -5)
			bottomRight	= new Vertex(5, 5)
			bottomLeft	= new Vertex(-5, 5)

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

			super model, topLeft, topRight, bottomRight, bottomLeft

	return ns
