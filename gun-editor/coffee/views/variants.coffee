define ['core/canvas', 'core/util'], (canvas, util) ->
	ns = {}

	relativePos = (e, $el) ->
		parentOffset = $el.parent().offset()

		return {
			x: e.pageX - parentOffset.left
			y: e.pageY - parentOffset.top
		}

	class DefaultState
		constructor: (@view) ->

		mouseDown: (e) ->
			if e.which is 1
				thingOfInterest = @view.thingOfInterest

				if thingOfInterest?
					if thingOfInterest.shape?
						@view.state = new DraggingShape @view, thingOfInterest.shape
						return

		render: ->
			thingOfInterest = @view.thingOfInterest

			if thingOfInterest?
				if thingOfInterest.shape?
					@view.highlightShape thingOfInterest.shape

	class DraggingShape
		constructor: (@view, @shape) ->
			mousePos = @view.realMousePos
			@offsets = []
			for vertex in @shape.vertices
				@offsets.push
					x: mousePos.x - vertex.x,
					y: mousePos.y - vertex.y

		mouseMove: ->
			mousePos = @view.realMousePos

			for index in [0...@shape.vertices.length]
				vertex		= @shape.vertices[index]
				offset		= @offsets[index]

				vertex.x	= mousePos.x - offset.x
				vertex.y	= mousePos.y - offset.y

		mouseUp: ->
			@view.state = new DefaultState @view

		render: ->
			@view.highlightShape @shape

	ns.VariantViewer = Backbone.View.extend
		events:
			'mousemove': 'render'
			'mousedown': 'render'
			'mouseup': 'render'

		initialize: ->
			Backbone.View.prototype.initialize.apply this, arguments

			width = 600
			height = 600

			@scale = {
				x: width / 32,
				y: height / 32
			}

			@canvas = new canvas.Canvas width: width, height: height
			@$el.append @canvas.$el

			@canvas.$el
				.attr('oncontextmenu', 'return false;')
				.mousedown (e) =>
					e.preventDefault()

					@mousePos = relativePos e, @$el
					@state.mouseDown e if @state.mouseDown

				.mouseup (e) =>
					e.preventDefault()
					@state.mouseUp e if @state.mouseUp

				.mousemove (e) =>
					@mousePos = relativePos e, @$el
					@state.mouseMove e if @state.mouseMove

			@state = new DefaultState this

			Object.defineProperty this, "edgeOfInterest",
				get: => @getEdgeOfInterest()

			Object.defineProperty this, "realMousePos",
				get: => @realPos @mousePos

			Object.defineProperty this, "thingOfInterest",
				get: => @getThingOfInterest()

			@mousePos = {x: 0, y: 0}

		vertexInDraggingRange: (vertex) ->
			return unless @mousePos

			{x: x, y: y} = @pixelPos vertex.pos

			dx = @mousePos.x - x
			dy = @mousePos.y - y

			return dx*dx + dy*dy < 25

		pixelPos: (pos) ->
			x: @canvas.width/2 + pos.x * @scale.x
			y: @canvas.height/2 + pos.y * @scale.y

		realPos: (pos) ->
			x: (pos.x - @canvas.width/2) / @scale.x
			y: (pos.y - @canvas.height/2) / @scale.y

		drawEdge: (from, to) ->
				{x: fromX, y: fromY}	= from
				{x: toX, y: toY}	= to

				context = @canvas.context
				context.beginPath()
				context.moveTo fromX, fromY
				context.lineTo toX, toY
				context.strokeStyle = "blue"
				context.lineWidth = 1
				context.stroke()

		drawVertex: (vertex) ->
			{x: pixelX, y: pixelY} = @pixelPos vertex.pos
			
			context = @canvas.context
			context.beginPath()
			context.arc pixelX, pixelY, 4, 0, 2 * Math.PI, false
			context.fillStyle = "red"
			context.fill()

		getThingOfInterest: ->
			mousePos = @realMousePos

			for shape in @model.get 'pieces'
				if util.pointInPoly mousePos, shape.vertices
					return {shape: shape}

			return null

		highlightShape: (shape) ->
			@renderShape shape, color: "blue", lineWidth: 3

		renderShape: (shape, opts) ->
			return unless shape.vertices.length > 0

			opts or= {}

			context = @canvas.context
			context.beginPath()

			lastVertex	= shape.vertices[shape.vertices.length - 1]
			pixelPos	= @pixelPos lastVertex
			context.moveTo pixelPos.x, pixelPos.y

			for vertex in shape.vertices
				pixelPos = @pixelPos vertex
				context.lineTo pixelPos.x, pixelPos.y

			context.fillStyle	= opts.color or shape.color or "red"
			context.strokeStyle	= "black"
			context.lineWidth	= opts.lineWidth or 1
			context.fill()
			context.stroke()

		render: ->
			@canvas.clear()

			@renderShape shape for shape in @model.get 'pieces'

			@state.render @canvas if @state.render
	return ns
