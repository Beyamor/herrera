define ['core/canvas', 'core/input', 'core/debug'], (cnvs, input, debug) ->

	return {
		loop: ->
			newTime = new Date
			@elapsed =  (newTime - @previousTime) * 0.001
			debug.showFPS @elapsed

			if @hasFocus
				@scene.update() if @scene

				@canvas.clear()
				@scene.render() if @scene

			@previousTime = newTime

		start: ->
			debug.init this
			@init() if @init

			# there's better ways to do this (request anim)
			# but for now, who cares
			@previousTime = new Date
			setInterval =>
				@loop()
			, 1000 / @fps

		launch: (opts) ->
			@hasFocus	= true
			@width		= opts.width
			@height		= opts.height
			@fps		= (opts.fps or 30)
			@init		= opts.init

			@container = $("##{opts.id}")
				.width(@width)
				.height(@height)
				.focusin(=> @hasFocus = true)
				.focusout(=> @hasFocus = false)

			@canvas = new cnvs.Canvas {
				width: @width
				height: @height
				clearColor: (opts.clearColor or 'white')
			}
			@container.append @canvas.$el

			@container.attr('tabindex', 0).focus()
			input.watch @container

			if @assets
				queue = new createjs.LoadQueue true
				queue.addEventListener 'complete', => @start()
				queue.addEventListener 'fileload', (e) ->
					debug.logType 'load', "loaded #{e.item.src}"
					
				for [id, src] in @assets
					queue.loadFile {id: id, src: src}

				# cool. uh, now, let's give 'em some way of getting those assets
				@assets = {
					get: (which) ->
						result = queue.getResult which
						throw new Error "Uknown asset #{which}" unless result
						return result
				}
			else
				@start()
	}
