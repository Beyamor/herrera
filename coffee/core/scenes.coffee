define ['core/debug', 'core/app', 'core/cameras', 'core/util', 'core/entities', 'core/particles'],
	(debug, app, cameras, util, entities, particles) ->

		class Scene
			constructor: ->
				@camera		= new cameras.Camera
				@entities	= new entities.EntityList
				@particles	= new particles.ParticleSystem this

			add: (e) ->
				return unless e?
				e.scene = this
				@entities.add e
				e.added() if e.added?

			remove: (e) ->
				return unless e?
				e.removed() if e.removed?
				@entities.remove e
				e.scene = null

			update: ->
				@entities.update()
				@particles.update()
				@camera.update()

			render: ->
				# TODO: maybe merge entity and particle lists
				@entities.render()
				@particles.render()

				if debug.isEnabled 'hitboxes'
					for entity in @entities.list
						context = app.canvas.context
						context.beginPath()
						context.rect(
							entity.pos.x + entity.offset.x - @camera.x,
							entity.pos.y + entity.offset.y - @camera.y,
							entity.width,
							entity.height
						)
						context.strokeStyle = 'red'
						context.stroke()
		return {
			Scene: Scene
		}
