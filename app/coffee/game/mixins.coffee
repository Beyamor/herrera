define ['core/mixins', 'core/app', 'core/util'],
	(mixins, app, util) ->
		ns = {}

		mixins.defineAll
			straightMover: ({speed: speed, direction: direction}) ->
				speed		= util.realizeArg speed
				direction	= util.realizeArg direction
				vx		= speed * Math.cos(direction)
				vy		= speed * Math.sin(direction)

				initialize: ->
					@vel.x = speed * Math.cos(direction)
					@vel.y = speed * Math.sin(direction)

			lifespan: (lifespan) ->
				lifespan = util.realizeArg lifespan

				initialize: ->
					@elapsedLife = 0

				update: ->
					@elapsedLife += app.elapsed

					if @elapsedLife >= lifespan and @scene
						@scene.remove this

		return ns
