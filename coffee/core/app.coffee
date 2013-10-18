define ['core/canvas', 'core/input'], (cnvs, input) ->

	return {
		loop: ->
			newTime = new Date
			@elapsed =  (newTime - @previousTime) * 0.001

			@scene.update() if @scene

			@canvas.clear()
			@scene.render() if @scene

			@previousTime = newTime

		start: ->
			@init() if @init

			# there's better ways to do this (request anim)
			# but for now, who cares
			@previousTime = new Date
			setInterval =>
				@loop()
			, 1000 / @fps

		launch: (opts) ->
			@width	= opts.width
			@height	= opts.height
			@fps	= (opts.fps or 30)
			@init	= opts.init

			@canvas = new cnvs.Canvas {
				width: @width
				height: @height
				id: opts.id
				clearColor: (opts.clearColor or 'white')
			}
			@canvas.$el.attr('tabindex', 0).focus()

			input.watch @canvas.$el

			if @assets
				queue = new createjs.LoadQueue true
				queue.addEventListener 'complete', => @start()
				queue.addEventListener 'fileload', (e) -> console.log "loaded #{e.item.src}"
					
				for [id, src] in @assets
					queue.loadFile {id: id, src: src}

				# cool. uh, now, let's give 'em some way of getting those assets
				@assets = {
					get: (which) -> queue.getResult which
				}
			else
				@start()
	}
