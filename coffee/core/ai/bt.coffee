# behaviour trees, dude
define ['core/app', 'core/util'], (app, util) ->
	ns = {}

	SUCCESS		= 0
	FAILURE		= 1
	RUNNING		= 2

	ns.SUCCESS = SUCCESS
	ns.FAILURE = FAILURE
	ns.RUNNING = RUNNING

	ns.delay = (duration) ->
		begin: ->
			@elapsed = 0

		update: ->
			@elapsed += app.elapsed

			if @elapsed < duration
				return RUNNING
			else
				return SUCCESS

	ns.randomDelay = (min, max) ->
		begin: ->
			@delay = ns.delay util.random.inRange(min, max)
			@delay.begin()

		update: ->
			return @delay.update()

	ns.loop = (children...) ->
		begin: ->
			@index		= 0
			@pendingBegin	= true

		update: ->
			child = children[@index]

			if @pendingBegin
				@pendingBegin = false
				child.begin()

			result = child.update()
			if result is SUCCESS
				@index		= (@index + 1) % children.length
				@pendingBegin	= true

			if result isnt FAILURE
				return RUNNING
			else
				return FAILURE

	ns.forever = (child) ->
		pendingBegin: true

		update: ->
			if @pendingBegin
				@pendingBegin = false
				child.begin()

			result = child.update()
			if result is FAILURE
				@pendingBegin = true

	ns.branch = (children...) ->
		begin: ->
			@running = -1

		update: ->
			index = 0
			while index < children.length
				child = children[index]
				child.begin() if index isnt @running

				result = child.update()
				switch result
					when RUNNING
						@running = index
						return RUNNING
					when SUCCESS
						@running = -1
						return SUCCESS
					else
						++index

			return FAILURE

	ns.cond = (check, body) ->
		begin: ->
			check.begin()
			@bodyBegun = false

		update: ->
			result = check.update()
			return FAILURE if result is FAILURE

			unless @bodyBegun
				@bodyBegun = true
				body.begin()

			return body.update()

	ns.concurrently = (children...) ->
		begin: ->
			child.begin() for child in children

		update: ->
			allSuccess = true
			for child in children
				result = child.update()
				return FAILURE if result is FAILURE
				allSuccess and= (result is SUCCESS)

			if allSuccess
				return SUCCESS
			else
				return RUNNING

	return ns
