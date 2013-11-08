define ['core/mixins', 'core/app'],
	(mixins, app) ->
		ns = {}

		mixins.defineAll
			straightMover: ({speed: speed, direction: direction}) ->
				vx = speed * Math.cos(direction)
				vy = speed * Math.sin(direction)

				initialize: ->
					@vel.x = speed * Math.cos(direction)
					@vel.y = speed * Math.sin(direction)

			lifespan: (lifespan) ->
				initialize: ->
					@elapsedLife = 0

				update: ->
					@elapsedLife += app.elapsed

					if @elapsedLife >= lifespan and @scene
						@scene.remove this

		return ns
