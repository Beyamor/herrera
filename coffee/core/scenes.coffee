define ['core/debug', 'core/app', 'core/cameras', 'core/util', 'core/entities'],
	(debug, app, cameras, util, entities) ->

		class Scene
			constructor: ->
				@camera		= new cameras.Camera
				@entities	= new entities.EntityList

			add: (e) ->
				return unless e?
				e.scene = this
				@entities.add e

			remove: (e) ->
				return unless e?
				@entities.remove e
				e.scene = null

			update: ->
				@entities.update()
				@camera.update()

			render: ->
				@entities.render()

				if debug.isEnabled 'hitboxes'
					for entity in @entities.entities
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
