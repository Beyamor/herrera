define ['core/canvas'], (cnvs) ->
	Canvas = cnvs.Canvas

	class Rect
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

	return {
		Rect: Rect
	}
