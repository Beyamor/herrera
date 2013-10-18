define ->
	class Scene
		constructor: ->
			@entities = []

		add: (e) ->
			return unless e?
			@entities.push e

		remove: (e) ->
			return unless e?
			index = @entities.indexOf e
			return unless index >= -1
			@entities.splice index, 1

		update: ->
			entity.update() for entity in @entities

		render: ->
			entity.render() for entity in @entities

	return {
		Scene: Scene
	}