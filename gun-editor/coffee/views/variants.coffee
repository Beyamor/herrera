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

			@vertices	= @model.get 'vertices'
			@edges		= @model.get 'edges'

			@canvas.$el
				.attr('oncontextmenu', 'return false;')
				.mousedown (e) =>
					e.preventDefault()

					@draggedVertex	= null
					@lastMousePos	= relativePos e, @$el

					if @edgeBeingPlaced
						if e.which is 1
							vertexOfInterest = @vertexOfInterest()
							if vertexOfInterest
								@edgeBeingPlaced.to = vertexOfInterest
								@edges.push @edgeBeingPlaced
								@edgeBeingPlaced = null

						else if e.which is 3
							@edgeBeingPlaced = null

					else
						vertexOfInterest = @vertexOfInterest()
						if vertexOfInterest
							if e.which is 1
								@draggedVertex = vertexOfInterest

							else if e.which is 3
								@edgeBeingPlaced = {
									from: vertexOfInterest
								}

				.mouseup (e) =>
					e.preventDefault()

					@draggedVertex = null

				.mousemove (e) =>
					@lastMousePos	= relativePos e, @$el
					realPos		= @realPos @lastMousePos

					if @draggedVertex
						@draggedVertex.pos.x = realPos.x
						@draggedVertex.pos.y = realPos.y

		vertexOfInterest: ->
			return null unless @lastMousePos

			for vertex in @vertices
				return vertex if @vertexInDraggingRange vertex

			return null

		vertexInDraggingRange: (vertex) ->
			return unless @lastMousePos

			{x: x, y: y} = @pixelPos vertex.pos

			dx = @lastMousePos.x - x
			dy = @lastMousePos.y - y

			return dx*dx + dy*dy < 25

		pixelPos: (pos) ->
			x: @canvas.width/2 + pos.x * @scale.x
			y: @canvas.height/2 + pos.y * @scale.y

		realPos: (pos) ->
			x: (pos.x - @canvas.width/2) / @scale.x
			y: (pos.y - @canvas.height/2) / @scale.y

		render: ->
			@canvas.clear()

			for {from: from, to: to} in @edges
				{x: fromX, y: fromY}	= @pixelPos from.pos
				{x: toX, y: toY}	= @pixelPos to.pos

				context = @canvas.context
				context.beginPath()
				context.moveTo fromX, fromY
				context.lineTo toX, toY
				context.strokeStyle = "blue"
				context.stroke()

			for vertex in @vertices
				{x: pixelX, y: pixelY} = @pixelPos vertex.pos
				
				context = @canvas.context
				context.beginPath()
				context.arc pixelX, pixelY, 4, 0, 2 * Math.PI, false
				context.fillStyle = "red"
				context.fill()

				if @lastMousePos and not @draggedVertex and @vertexInDraggingRange vertex, @lastMousePos
					context.moveTo pixelX + 7, pixelY
					context.arc pixelX, pixelY, 7, 0, 2 * Math.PI, false
					context.strokeStyle = "black"
					context.stroke()

			if @edgeBeingPlaced and @lastMousePos
				from			= @edgeBeingPlaced.from
				{x: fromX, y: fromY}	= @pixelPos from.pos
				{x: toX, y: toY}	= @lastMousePos

				context = @canvas.context
				context.beginPath()
				context.moveTo fromX, fromY
				context.lineTo toX, toY
				context.strokeStyle = "blue"
				context.stroke()

	return ns
