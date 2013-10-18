define ['core/debug', 'core/app'], (debug, app) ->
	class Scene
		constructor: ->
			@entities = []

		add: (e) ->
			return unless e?
			e.scene = this
			@entities.push e
			@entities.sort (a, b) -> b.layer - a.layer

		remove: (e) ->
			return unless e?

			index = @entities.indexOf e
			return unless index >= -1

			@entities[e].scene = null
			@entities.splice index, 1

		update: ->
			entity.update() for entity in @entities

		render: ->
			entity.render() for entity in @entities

			if debug.isEnabled 'hitboxes'
				for entity in @entities
					context = app.canvas.context
					context.beginPath()
					context.rect(
						entity.pos.x + entity.offset.x,
						entity.pos.y + entity.offset.y,
						entity.width,
						entity.height
					)
					context.strokeStyle = 'red'
					context.stroke()

	return {
		Scene: Scene
	}
