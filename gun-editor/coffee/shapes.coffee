define ['core/util'], (util) ->
	ns = {}

	class Pin
		constructor: (@shape) ->
			@vertices = []

		moveTo: (x, y) ->
			for vertex in @vertices
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
				@shape.pins.remove this

		contains: (vertex) ->
			@vertices.contains vertex

	class Vertex
		constructor: (@x, @y) ->

		moveTo: (@x, @y) ->
			if @pin and not @isBeingMoved
				@pin.moveTo @x, @y

			if @onMove and not @isBeingMoved
				@onMove()

		pinTo: (other) ->
			return if other is this or other.shape is @shape

			if @pin
				@pin.add other
			else if other.pin
				other.pin.add this
			else
				@shape.createPin other, this

		unpin: ->
			@pin.remove this if @pin

		applyVertexConstraints: ->
			return unless @vertexConstraints

			for constraint in @vertexConstraints()
				x = constraint.x or constraint.vertex.x
				y = constraint.y or constraint.vertex.y

				constraint.vertex.moveTo x, y

	class Shape
		constructor: (@vertices...) ->
			vertex.shape = this for vertex in @vertices

			@pins = []

		createPin: (v1, v2) ->
			pin = new Pin this
			pin.add v1
			pin.add v2
			@pins.push pin

	class ns.Triangle extends Shape
		constructor: ->
			super(
				new Vertex(0, -5),
				new Vertex(4.33, 2.5),
				new Vertex(-4.33, 2.5)
			)


	class ns.Quad extends Shape
		constructor: ->
			super(
				new Vertex(-5, -5),
				new Vertex(5, -5),
				new Vertex(5, 5),
				new Vertex(-5, 5)
			)

	class ns.Rectangle extends Shape
		constructor: ->
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

			super topLeft, topRight, bottomRight, bottomLeft

	return ns
