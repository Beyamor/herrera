define ['core/app', 'core/util', 'core/ai/bt'], (app, util, bt) ->
	ns = {}

	random = util.random

	class ns.CloseTo
		constructor: (@from, @to, @distance) ->

		begin: ->

		update: ->
			if util.distanceBetween(@from, @to()) <= @distance
				return bt.SUCCESS
			else
				return bt.FAILURE

	class ns.Flee
		constructor: (@entity, @target, args) ->
			@speed = args.speed or 200

		begin: ->

		update: ->
			direction = util.directionFrom @target(), @entity

			@entity.vel.x = Math.cos(direction) * @speed
			@entity.vel.y = Math.sin(direction) * @speed

	class ns.WanderNearby
		constructor: (@entity, args) ->
			@speed		= args.speed or 200
			@radius		= args.radius or 50
			@threshold	= (args.threshold * args.threshold) or 5
			@timeout	= args.timeout
			@elapsed	= 0

		begin: ->
			@elapsed	= 0
			direction	= random.angle()
			radius		= random.inRange 0, @radius
			@destination =
				x: @entity.x + Math.cos(direction) * radius
				y: @entity.y + Math.sin(direction) * radius


		update: ->
			if @timeout?
				@elapsed += app.elapsed
				if @elapsed >= @timeout
					return bt.FAILURE

			if not @timeout? or @elapsed <= @timeout
				dx = @destination.x - @entity.x
				dy = @destination.y - @entity.y

				if dx*dx + dy*dy <= @threshold
					@entity.vel.x = @entity.vel.y = 0
					return bt.SUCCESS
				else
					direction	= Math.atan2 dy, dx
					@entity.vel.x	= Math.cos(direction) * @speed
					@entity.vel.y	= Math.sin(direction) * @speed
					return bt.RUNNING

	return ns
