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
	ns.delay = (duration) -> new ns.Delay duration

	class ns.RandomDelay
		constructor: (@minDuration, @maxDuration) ->

		begin: ->
			@delay = new ns.Delay util.random.inRange(@minDuration, @maxDuration)
			@delay.begin()

		update: ->
			return @delay.update()
	ns.randomDelay = (min, max) -> new ns.RandomDelay min, max

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
	ns.loop = (children...) -> new ns.Loop children

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
	ns.forever = (child) -> new ns.ForeverRoot child

	class ns.OrderedSelector
		constructor: (@children) ->

		begin: ->
			@running = -1

		update: ->
			index = 0
			while index < @children.length
				child = @children[index]
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
	ns.branch = (children...) -> new ns.OrderedSelector children

	class ns.Concurrent
		constructor: (@children) ->

		begin: ->
			child.begin() for child in @children

		update: ->
			allSuccess = true
			for child in @children
				result = child.update()
				return FAILURE if result is FAILURE
				allSuccess and= (result is SUCCESS)

			if allSuccess
				return SUCCESS
			else
				return RUNNING
	ns.concurrently = (children...) -> new ns.Concurrent children

	return ns
