define ['core/canvas', 'core/input', 'core/debug'], (cnvs, input, debug) ->

	return {
		loop: ->
			newTime = new Date
			@elapsed =  (newTime - @previousTime) * 0.001
			debug.showFPS @elapsed

			if @hasFocus
				input.update()

				@scene.update() if @scene

				@canvas.clear()
				@scene.render() if @scene

			@previousTime = newTime

		start: ->
			@loadScreen.remove()
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
				backgroundColor: (opts.backgroundColor or 'white')
			}
			@container.append @canvas.$el

			@loadScreen = $('<div>')
					.addClass('load-screen')
					.text('Loading: 0%')
			@container.append @loadScreen

			@container.attr('tabindex', 0).focus()
			input.watch @container

			Object.defineProperty this, "scene",
				get: =>
					@_scene

				set: (newScene) =>
					if @_scene? and @_scene.end?
						@_scene.end()
					@_scene = newScene
					if @_scene? and @_scene.begin?
						@_scene.begin()

			@numberOfThingsToLoad = @numberOfThingsLoaded = 0

			if @assets? and @assets.length isnt 0
				@numberOfThingsToLoad += @assets.length
				@loadAssets()
			else
				@assetsLoaded = true

			if @templates? and @templates.length isnt 0
				@numberOfThingsToLoad += @templates.length
				@loadTemplates()
			else
				@templatesLoaded = true

			@tryStarting()

		tryStarting: ->
			return unless @assetsLoaded and @templatesLoaded
			@start()

		updateLoadStatus: ->
			++@numberOfThingsLoaded
			percentage =
				if @numberOfThingsToLoad isnt 0
					(@numberOfThingsLoaded / @numberOfThingsToLoad * 100).toPrecision 3
				else
					100

			@loadScreen.text "Loading: #{percentage}%"
		
		loadAssets: ->
			queue = new createjs.LoadQueue true
			queue.addEventListener 'complete', =>
				@assetsLoaded = true
				@tryStarting()
			queue.addEventListener 'fileload', (e) =>
				debug.logType 'load', "loaded #{e.item.src}"
				@updateLoadStatus()
				
			for [id, src] in @assets
				queue.loadFile {id: id, src: src}

			# also, like, give 'em a way to access the assets
			@assets = {
				get: (which) ->
					result = queue.getResult which
					throw new Error "Uknown asset #{which}" unless result
					return result
			}

		loadTemplates: ->
			templates		= @templates
			@compiledTemplates	= {}

			# ugh doing this ad hoc b/c require.js' text plugin don't work w/o optimizer
			templatesLoaded		= 0
			templatesToLoad		= @templates.length

			for [alias, url] in templates
				do (alias, url) =>
					$.ajax
						url:
							if debug.isEnabled
								"#{url}?bust=#{new Date().getTime()}"
							else
								url
						success: (template) =>
							@compiledTemplates[alias] = Handlebars.compile template
							++templatesLoaded

							@updateLoadStatus()

							if templatesLoaded >= templatesToLoad
								@templatesLoaded = true
								@tryStarting()
						error: ->
							console.log "Couldn't load #{url}"

			@templates = {
				get: (which) =>
					result = @compiledTemplates[which]
					throw new Error "Unknown asset #{which}" unless result
					return result
				
				compile: (which, context) =>
					template = @templates.get which
					template context
			}
	}
