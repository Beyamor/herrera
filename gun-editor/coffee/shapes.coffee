define ['core/util'], (util) ->
	ns = {}

	class Vertex
		constructor: (@x, @y) ->
			@pinnedVertices = []

		moveTo: (@x, @y) ->
			for vertex in @pinnedVertices
				vertex.moveTo @x, @y

		pinTo: (pin) ->
			return if pin is this or pin.shape is @shape or pin.pin is this
			@pin = pin
			@pin.pinnedVertices.push this
			@moveTo @pin.x, @pin.y

		unpin: ->
			return unless @pin

			@pin.pinnedVertices.remove this
			@pin = null

	class Shape
		constructor: (@vertices...) ->
			vertex.shape = this for vertex in @vertices

	class ns.Rectangle extends Shape
		constructor: ->
			super(
				new Vertex(-5, -5),
				new Vertex(5, -5),
				new Vertex(5, 5),
				new Vertex(-5, 5)
			)

	return ns
