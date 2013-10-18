define ['core/app', 'core/canvas'], (app, cnvs) ->
	Canvas = cnvs.Canvas
	ns = {}

	class ns.Rect
		constructor: (width, height, color) ->
			@canvas = new Canvas {width: width, height: height}
			context = @canvas.context
			context.beginPath()
			context.rect 0, 0, width, height
			context.fillStyle = color
			context.fill()
			context.closePath()

		render: (target, point) ->
			target.context.drawImage @canvas.el, point.x, point.y

	class ns.Image
		constructor: (asset) ->
			@img = app.assets.get asset

		render: (target, point) ->
			target.context.drawImage @img, point.x, point.y

	return ns
