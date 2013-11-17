define {
	log: (args...) ->
		return unless @enabled
		console.log args.join ', '

	logType: (type, args...) ->
		return unless @types and @types[type]
		@log.apply this, args

	config: (opts) ->
		for k, v of opts
			@[k] = v
			
	init: (app) ->
		@screen = $('<div class="debug-screen">')
		app.container.append @screen

		if @isEnabled 'fps'
			@fpsSamples = []
			@screen.append $('<div class="fps">')

	showFPS: (elapsed) ->
		return unless @isEnabled 'fps'

		@fpsSamples.push elapsed
		@fpsSamples.shift() if @fpsSamples.length > 3
		elapsedAvg = 0
		(elapsedAvg += sample) for sample in @fpsSamples
		elapsedAvg /= @fpsSamples.length

		$('.fps', @screen).text(Math.floor(1 / elapsedAvg))

	isEnabled: (type) ->
		return @enabled and @types[type]

	toggle: (type) ->
		@types[type] = not @types[type]
}
