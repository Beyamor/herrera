define ['core/util'], (util) ->
	ns = {}

	class Pin
		constructor: (@shape) ->
			@vertices = []

		moveTo: (x, y) ->
			for vertex in @vertices
				vertex.isBeingMoved = true
				vertex.moveTo x, y
				vertex.isBeingMoved = false

		add: (vertex) ->
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

		pinTo: (other) ->
			return if other is this or other.shape is @shape

			@shape.addPin this, other

		unpin: ->
			@pin.remove this if @pin

	class Shape
		constructor: (@vertices...) ->
			vertex.shape = this for vertex in @vertices

			@pins = []

		addPin: (v1, v2) ->
			for pin in @pins
				if pin.contains v1
					pin.add v2
					return

				else if pin.contains v2
					pin.add v1
					return

			pin = new Pin this
			pin.add v1
			pin.add v2
			@pins.push pin


	class ns.Rectangle extends Shape
		constructor: ->
			super(
				new Vertex(-5, -5),
				new Vertex(5, -5),
				new Vertex(5, 5),
				new Vertex(-5, 5)
			)

	return ns
