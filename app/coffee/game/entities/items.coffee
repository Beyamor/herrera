define ['core/entities', "game/guns",'game/guns/sprites'],
	(entities, guns, gunSprites) ->
		ns = {}

		class Gun extends entities.Entity
			constructor: (@model) ->
				super
					graphic: new gunSprites.GunSprite @model.model
					width: 24
					layer: 150
					type: 'gun'
					centered: true
					mixins:
						updates: [
							@model
						]

		getItemClass = multimethod()
				.dispatch (i) ->
					i.constructor
				.when guns.GunModel, -> Gun

		ns.for = (i) ->
			new (getItemClass i) i

		return ns
