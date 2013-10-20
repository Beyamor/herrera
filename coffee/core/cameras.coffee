define ['core/util', 'core/app'], (util, app) ->
	ns = {}

	class ns.Camera
		constructor: ->
			@pos = {x: 0, y: 0}

		update: ->
			# nothing

		@accessors
			x:
				get: -> @pos.x
				set: (x) -> @pos.x = x

			y:
				get: -> @pos.y
				set: (y) -> @pos.y = y

			width:
				get: -> app.width

			height:
				get: -> app.height

			left:
				get: -> @x

			right:
				get: -> @left + @width

			top:
				get: -> @y

			bottom:
				get: -> @top + @height

	class ns.CameraWrapper extends ns.Camera
		constructor: (@base) ->

		update: ->
			@base.update()

		@accessors
			x:
				get: -> @base.x
				set: (x) -> @base.x = x

			y:
				get: -> @base.y
				set: (y) -> @base.y = y

			width:
				get: -> @base.width

			height:
				get: -> @base.height

	class ns.EntityFollower extends ns.CameraWrapper
		constructor: (@ent, base) ->
			super base

		update: ->
			super()
			@x = @ent.x - app.width / 2
			@y = @ent.y - app.height / 2

	return ns
