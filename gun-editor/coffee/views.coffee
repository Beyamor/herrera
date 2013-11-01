define ['core/canvas'], (canvas) ->
	ns = {}

	ns.PartsBrowser = Backbone.View.extend
		el: "#parts-browser"

		template: _.template($('#parts-browser-template').html())

		render: ->
			@$el.html @template @model.toJSON()

			return this

	ns.VariantViewer = Backbone.View.extend
		el: $ '#variant-viewer'

		initialize: ->
			Backbone.View.prototype.initialize.apply this, arguments

			@model.on 'change:selectedVariant', => @render()

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

			selectedVariant = @model.get 'selectedVariant'
			return unless selectedVariant

			for {pos: pos} in selectedVariant.get 'vertices'
				pixelX = @canvas.width/2 + pos.x * @scale.x
				pixelY = @canvas.height/2 + pos.y * @scale.y

				console.log pixelX, pixelY

				context = @canvas.context
				context.beginPath()
				context.arc pixelX, pixelY, 4, 0, 2 * Math.PI, false
				context.fillStyle = "red"
				context.fill()
	return ns
