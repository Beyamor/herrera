define ['core/graphics'], (gfx) ->
	canvas = new gfx.Canvas {
		id: 'game'
		clearColor: 'white'
	}

	canvas.clear()
	canvas.context.beginPath()
	canvas.context.rect 50, 50, 100, 100
	canvas.context.fillStyle = 'red'
	canvas.context.fill()
