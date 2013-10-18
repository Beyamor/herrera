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

		render: (target, point, camera) ->
			x = point.x - camera.x
			y = point.y - camera.y
			target.context.drawImage @canvas.el, x, y

	class ns.Image
		constructor: (asset) ->
			@img		= app.assets.get asset
			@canvas		= new Canvas width: @img.width, height: @img.height
			@origin		= x: 0, y: 0
			@rotation	= 0
			@dirty		= true
			@width		= @img.width
			@height		= @img.height

		centerOrigin: ->
			@origin.x = @img.width / 2
			@origin.y = @img.height / 2
			@diry = true
			return this

		rotate: (rotation) ->
			if rotation != @rotation
				@rotation = rotation
				@dirty = true
			return this

		prerender: ->
			# I kinda feeel like this is wrong,
			# but who cares whatever
			@canvas.clear()
			context = @canvas.context
			context.save()

			context.translate @origin.x , @origin.y
			if @rotation isnt 0
				context.rotate @rotation

			context.drawImage @img, -@origin.x, -@origin.y
			context.restore()
			@dirty = false

		render: (target, point, camera) ->
			@prerender() if @dirty
			x = point.x - @origin.x - camera.x
			y = point.y - @origin.y - camera.y
			target.context.drawImage @canvas.el, x, y

	return ns
