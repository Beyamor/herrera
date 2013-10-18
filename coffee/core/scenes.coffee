define ['core/debug', 'core/app'], (debug, app) ->
	class Scene
		constructor: ->
			@entities	= []
			@toAdd		= []
			@toRemove	= []

		add: (e) ->
			return unless e?
			@toAdd.push e

		remove: (e) ->
			return unless e?
			@toRemove.push e

		update: ->
			entity.update() for entity in @entities

			if @toAdd.length isnt 0
				for entity in @toAdd
					entity.scene = this
					@entities.push entity
				@entities.sort (a, b) -> b.layer - a.layer
				@toAdd = []

			if @toRemove.length isnt 0
				for entity in @toRemove
					index = @entities.indexOf entity
					if index != -1
						@entities.splice index, 1
					entity.scene = null
				@toRemove = []

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

		collide: (e1, type) ->
			for e2 in @entities when e2 isnt e1 and e2.hasType type
				noCollision = (e1.right < e2.left or
						e1.left > e2.right or
						e1.bottom < e2.top or
						e1.top > e2.bottom)
				return e2 if not noCollision
			return null

	return {
		Scene: Scene
	}
