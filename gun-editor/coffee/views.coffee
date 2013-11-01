define ['core/canvas'], (canvas) ->
	ns = {}

	ns.PartsBrowser = Backbone.View.extend
		el: "#parts-browser"

		template: _.template($('#parts-browser-template').html())

		render: ->
			@$el.html @template @model.toJSON()

			return this

	relativePos = (e, $el) ->
		parentOffset = $el.parent().offset()

		return {
			x: e.pageX - parentOffset.left
			y: e.pageY - parentOffset.top
		}

	ns.VariantViewer = Backbone.View.extend
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

			@vertices = @model.get 'vertices'

			@canvas.$el
				.attr('oncontextmenu', 'return false;')
				.mousedown (e) =>
					e.preventDefault()
					@draggedVertex = null
					mousePos = relativePos e, @$el

					if e.which is 1
						for vertex in @vertices
							{x: x, y: y} = @pixelPos vertex.pos

							dx = mousePos.x - x
							dy = mousePos.y - y

							if dx*dx + dy*dy < 25
								@draggedVertex = vertex
								return

				.mouseup (e) =>
					e.preventDefault()
					@draggedVertex = null

				.mousemove (e) =>
					mousePos	= relativePos e, @$el
					realPos		= @realPos mousePos

					if @draggedVertex
						@draggedVertex.pos.x = realPos.x
						@draggedVertex.pos.y = realPos.y

						@render()

		pixelPos: (pos) ->
			x: @canvas.width/2 + pos.x * @scale.x
			y: @canvas.height/2 + pos.y * @scale.y

		realPos: (pos) ->
			x: (pos.x - @canvas.width/2) / @scale.x
			y: (pos.y - @canvas.height/2) / @scale.y

		render: ->
			@canvas.clear()

			for {pos: pos} in @vertices
				{x: pixelX, y: pixelY} = @pixelPos pos
				
				context = @canvas.context
				context.beginPath()
				context.arc pixelX, pixelY, 4, 0, 2 * Math.PI, false
				context.fillStyle = "red"
				context.fill()
	return ns
