define ['core/util'], (util) ->
	ns = {}

	class Vertex
		constructor: (@x, @y) ->

		moveTo: (@x, @y) ->

	class Shape
		constructor: (@vertices...) ->

	class ns.Rectangle extends Shape
		constructor: ->
			super(
				new Vertex(-5, -5),
				new Vertex(5, -5),
				new Vertex(5, 5),
				new Vertex(-5, 5)
			)

	return ns
