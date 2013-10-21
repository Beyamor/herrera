# behaviour trees, dude
define ['core/app', 'core/util'], (app, util) ->
	ns = {}

	SUCCESS		= 0
	FAILURE		= 1
	RUNNING		= 2

	ns.SUCCESS = SUCCESS
	ns.FAILURE = FAILURE
	ns.RUNNING = RUNNING

	class ns.Delay
		constructor: (@duration) ->

		begin: ->
			@elapsed = 0

		update: ->
			@elapsed += app.elapsed

			if @elapsed < @duration
				return RUNNING
			else
				return SUCCESS

	class ns.RandomDelay
		constructor: (@minDuration, @maxDuration) ->

		begin: ->
			@delay = new ns.Delay util.random.inRange(@minDuration, @maxDuration)
			@delay.begin()

		update: ->
			return @delay.update()

	class ns.Loop
		constructor: (@children)->

		begin: ->
			@index		= 0
			@pendingBegin	= true

		update: ->
			child = @children[@index]

			if @pendingBegin
				@pendingBegin = false
				child.begin()

			result = child.update()
			if result is SUCCESS
				@index		= (@index + 1) % @children.length
				@pendingBegin	= true

			if result isnt FAILURE
				return RUNNING
			else
				return FAILURE

	class ns.ForeverRoot
		constructor: (@child) ->
			@pendingBegin = true

		update: ->
			if @pendingBegin
				@pendingBegin = false
				@child.begin()

			result = @child.update()
			if result is FAILURE
				@pendingBegin = true

	return ns
