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

		@define 'width',
			get: -> app.width

		@define 'height',
			get: -> app.height

		@define 'left',
			get: -> @x

		@define 'right',
			get: -> @left + @width

		@define 'top',
			get: -> @y

		@define 'bottom',
			get: -> @top + @height

	class ns.CameraWrapper extends ns.Camera
		constructor: (@base) ->

		update: ->
			@base.update()

		@define 'x',
			get: -> @base.x
			set: (x) -> @base.x = x

		@define 'y',
			get: -> @base.y
			set: (y) -> @base.y = y

		@define 'width',
			get: -> @base.width

		@define 'height',
			get: -> @base.height

	class ns.EntityFollower extends ns.CameraWrapper
		constructor: (@ent, base) ->
			super base

		update: ->
			super()
			@x = @ent.x - app.width / 2
			@y = @ent.y - app.height / 2

	return ns
