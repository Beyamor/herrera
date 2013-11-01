define ['core/canvas'], (canvas) ->
	ns = {}

	ns.PartsBrowser = Backbone.View.extend
		el: "#parts-browser"

		template: _.template($('#parts-browser-template').html())

		render: ->
			@$el.html @template @model.toJSON()

			return this

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

		render: ->
			@canvas.clear()

			for {pos: pos} in @model.get 'vertices'
				pixelX = @canvas.width/2 + pos.x * @scale.x
				pixelY = @canvas.height/2 + pos.y * @scale.y

				context = @canvas.context
				context.beginPath()
				context.arc pixelX, pixelY, 4, 0, 2 * Math.PI, false
				context.fillStyle = "red"
				context.fill()
	return ns
