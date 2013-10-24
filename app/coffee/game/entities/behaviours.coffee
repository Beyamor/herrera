define ['core/app', 'core/util', 'core/ai/bt'], (app, util, bt) ->
	ns = {}

	random = util.random

	ns.closeTo = (from, to, distance) ->
		from	= util.thunkWrap from
		to	= util.thunkWrap to

		begin: ->
		update: ->
			if util.distanceBetween(from(), to()) <= distance
				return bt.SUCCESS
			else
				return bt.FAILURE

	ns.flee = (entity, target, args) ->
		target		= util.thunkWrap target
		speed		= args.speed or 200
		minDistance	= args.minDistance

		begin: ->
		update: ->
			if minDistance?
				distance = util.distanceBetween entity, target()
				return bt.SUCCESS if distance >= minDistance

			direction = util.directionFrom target(), entity

			entity.vel.x = Math.cos(direction) * speed
			entity.vel.y = Math.sin(direction) * speed

			return bt.RUNNING

	ns.wanderNearby = (entity, args) ->
		speed		= args.speed or 200
		maxRadius	= args.radius or 50
		threshold	= (args.threshold * args.threshold) or 5
		timeout		= args.timeout

		begin: ->
			@elapsed	= 0
			direction	= random.angle()
			radius		= random.inRange 0, maxRadius
			@destination =
				x: entity.x + Math.cos(direction) * radius
				y: entity.y + Math.sin(direction) * radius

		update: ->
			if timeout?
				@elapsed += app.elapsed
				if @elapsed >= timeout
					return bt.FAILURE

			if not timeout? or @elapsed <= timeout
				dx = @destination.x - entity.x
				dy = @destination.y - entity.y

				if dx*dx + dy*dy <= threshold
					entity.vel.x = entity.vel.y = 0
					return bt.SUCCESS
				else
					direction	= Math.atan2 dy, dx
					entity.vel.x	= Math.cos(direction) * speed
					entity.vel.y	= Math.sin(direction) * speed
					return bt.RUNNING

	return ns
