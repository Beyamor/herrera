define ['core/app', 'core/util'], (app, util) ->
	ns = {}

	class ns.Delay
		constructor: (@duration) ->
			@elapsed	= 0
			@isBlocking	= true

		update: ->
			@elapsed += app.elapsed
			@isFinished = (@elapsed >= @duration)

	class ns.MoveTo
		constructor: (@entity, @pos, args) ->
			@speed		= args.speed or 200
			@threshold	= (args.threshold * args.threshold) or 5
			@isBlocking	= true
			@timeout	= args.timeout
			@elapsed	= 0

		update: ->
			if not @timeout? or @elapsed <= @timeout
				dx = @pos.x - @entity.x
				dy = @pos.y - @entity.y

				if dx*dx + dy*dy <= @threshold
					@entity.vel.x = @entity.vel.y = 0
					@isFinished = true
				else
					direction	= Math.atan2 dy, dx
					@entity.vel.x	= Math.cos(direction) * @speed
					@entity.vel.y	= Math.sin(direction) * @speed

			if @timeout?
				@elapsed += app.elapsed
				if @elapsed >= @timeout
					@isFinished = true

	class ns.ActionList
		constructor: ->
			@actions = []

		unshift: (action) ->
			action.list = this
			@actions.unshift action

		push: (action) ->
			action.list = this
			@actions.push action

		update: ->
			index = 0
			while index < @actions.length
				action = @actions[index]

				action.update()

				if action.isFinished
					action.onEnd() if action.onEnd?
					@actions.remove action

				else if action.isBlocking
					break

				++index

	return ns
