define ['core/canvas'], (canvas) ->
	ns = {}

	relativePos = (e, $el) ->
		parentOffset = $el.parent().offset()

		return {
			x: e.pageX - parentOffset.left
			y: e.pageY - parentOffset.top
		}

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

			@state = {}

			Object.defineProperty this, "edgeOfInterest",
				get: => @getEdgeOfInterest()

		getVertexOfInterest: ->
			return null unless @mousePos

			for vertex in @vertices
				return vertex if @vertexInDraggingRange vertex

			return null

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

		highlightVertexOfInterest: ->
			vertexOfInterest = @vertexOfInterest
			if vertexOfInterest
				pixelPos = @pixelPos vertexOfInterest.pos

				context = @canvas.context
				context.beginPath()
				context.arc pixelPos.x, pixelPos.y, 7, 0, 2 * Math.PI, false
				context.strokeStyle = "black"
				context.lineWidth = 2
				context.stroke()

		highlightEdgeOfInterest: ->
			edgeOfInterest = @edgeOfInterest
			if edgeOfInterest

				{x: fromX, y: fromY}	= @pixelPos edgeOfInterest.from.pos
				{x: toX, y: toY}	= @pixelPos edgeOfInterest.to.pos

				context = @canvas.context
				context.beginPath()
				context.moveTo fromX, fromY
				context.lineTo toX, toY
				context.strokeStyle = "black"
				context.lineWidth = 2
				context.stroke()

		render: ->
			@canvas.clear()

			@state.render @canvas if @state.render
	return ns
