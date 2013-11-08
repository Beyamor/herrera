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

			rotateGraphicToVel: ->
				update: ->
					if @vel.x isnt 0 or @vel.y isnt 0
						@graphic.rotate Math.atan2(@vel.y, @vel.x)

			updates: (thingsToUpdate) ->
				thingsToUpdate = _.map thingsToUpdate, util.thunkWrap

				update: ->
					for thingThunk in thingsToUpdate
						thing = thingThunk.call(this)
						thing.update() if thing?

		return ns
