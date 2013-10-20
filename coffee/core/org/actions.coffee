define ['core/app', 'core/util'], (app, util) ->
	ns = {}

	class ns.Delay
		constructor: (@duration) ->
			@elapsed	= 0
			@isBlocking	= true

		update: ->
			@elapsed += app.elapsed
			@isFinished = (@elapsed >= @duration)

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
