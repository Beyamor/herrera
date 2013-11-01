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

			if e.which is 1
				if vertexOfInterest
					@view.state = new DraggingVertexState @view, vertexOfInterest

			else if e.which is 2
				if vertexOfInterest
					@view.model.removeVertex vertexOfInterest
				else
					@view.model.addVertex(@view.realPos @view.mousePos)

			else if e.which is 3
				if vertexOfInterest
					@view.state = new AddingEdgeState @view, vertexOfInterest

		render: ->
			@view.highlightVertexOfInterest()

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
				context.stroke()

		highlightVertexOfInterest: ->
			vertexOfInterest = @vertexOfInterest
			if vertexOfInterest
				pixelPos = @pixelPos vertexOfInterest.pos

				context = @canvas.context
				context.beginPath()
				context.arc pixelPos.x, pixelPos.y, 7, 0, 2 * Math.PI, false
				context.strokeStyle = "black"
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
