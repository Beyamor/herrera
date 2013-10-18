define ['core/util', 'core/app'], (util, app) ->
	ns = {}

	class ns.Camera
		constructor: ->
			@pos = {x: 0, y: 0}

		update: ->
			# nothing

		@define 'x',
			get: -> @pos.x
			set: (x) -> @pos.x = x

		@define 'y',
			get: -> @pos.y
			set: (y) -> @pos.y = y

	class ns.CameraWrapper
		constructor: (@base) ->

		update: ->
			@base.update()

		@define 'x',
			get: -> @base.x
			set: (x) -> @base.x = x

		@define 'y',
			get: -> @base.y
			set: (y) -> @base.y = y

	class ns.EntityFollower extends ns.CameraWrapper
		constructor: (@ent, base) ->
			super base

		update: ->
			super()
			@x = @ent.x - app.width / 2
			@y = @ent.y - app.height / 2

	return ns
