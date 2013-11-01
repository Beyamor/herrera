define ['core/canvas'], (canvas) ->
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
			vertexOfInterest	= @view.vertexOfInterest
			edgeOfInterest		= @view.edgeOfInterest

			if e.which is 1
				if vertexOfInterest
					@view.state = new DraggingVertexState @view, vertexOfInterest

			else if e.which is 2
				if vertexOfInterest
					@view.model.removeVertex vertexOfInterest
				else if edgeOfInterest
					@view.model.removeEdge edgeOfInterest
				else
					@view.model.addVertex(@view.realPos @view.mousePos)

			else if e.which is 3
				if vertexOfInterest
					@view.state = new AddingEdgeState @view, vertexOfInterest

		render: ->
			if @view.vertexOfInterest
				@view.highlightVertexOfInterest()
			else if @view.edgeOfInterest
				@view.highlightEdgeOfInterest()

	class DraggingVertexState
		constructor: (@view, @vertex) ->

		mouseUp: (e) ->
			@view.state = new DefaultState @view

		mouseMove: (e) ->
			realPos = @view.realPos @view.mousePos

			@vertex.pos.x = realPos.x
			@vertex.pos.y = realPos.y

	class AddingEdgeState
		constructor: (@view, @from) ->

		mouseDown: (e) ->
			if e.which is 1
				vertexOfInterest = @view.vertexOfInterest
				return unless vertexOfInterest

				@view.model.addEdge
					from: @from
					to: vertexOfInterest

				@view.state = new DefaultState @view

			else if e.which is 3
				@view.state = new DefaultState @view

		render: ->
			@view.highlightVertexOfInterest()
			@view.drawEdge @view.pixelPos(@from.pos), @view.mousePos

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

			Object.defineProperty this, "vertices",
				get: => @model.get "vertices"

			Object.defineProperty this, "edges",
				get: => @model.get "edges"

			Object.defineProperty this, "vertexOfInterest",
				get: => @getVertexOfInterest()

			Object.defineProperty this, "edgeOfInterest",
				get: => @getEdgeOfInterest()

		getVertexOfInterest: ->
			return null unless @mousePos

			for vertex in @vertices
				return vertex if @vertexInDraggingRange vertex

			return null

		getEdgeOfInterest: ->
			return null unless @mousePos

			for edge in @edges
				from	= @pixelPos edge.from.pos
				to	= @pixelPos edge.to.pos
				dx	= to.x - from.x
				dy	= to.y - from.y
				length	= Math.sqrt(dx * dx + dy * dy)

				# first dot product
				toX	= (to.x - from.x) / length
				toY	= (to.y - from.y) / length
				mouseX	= @mousePos.x - from.x
				mouseY	= @mousePos.y - from.y
				dot	= toX * mouseX + toY * mouseY

				continue unless dot >= 0

				# second dot product
				fromX	= (from.x - to.x) / length
				fromY	= (from.y - to.y) / length
				mouseX	= @mousePos.x - to.x
				mouseY	= @mousePos.y - to.y
				dot	= fromX * mouseX + fromY * mouseY

				continue unless dot >= 0

				# proximity, yo
				distance = Math.sqrt(mouseX * mouseX + mouseY * mouseY) - dot
				continue unless distance <= 0.5 # whoa that's way to big, something's prolly wrong

				return edge

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

			for {from: from, to: to} in @edges
				@drawEdge @pixelPos(from.pos), @pixelPos(to.pos)

			for vertex in @vertices
				{x: pixelX, y: pixelY} = @pixelPos vertex.pos
				
				context = @canvas.context
				context.beginPath()
				context.arc pixelX, pixelY, 4, 0, 2 * Math.PI, false
				context.fillStyle = "red"
				context.fill()

			@state.render @canvas if @state.render
	return ns
