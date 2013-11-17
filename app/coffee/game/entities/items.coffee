define ['core/entities', "game/guns",'game/guns/sprites'],
	(entities, guns, gunSprites) ->
		ns = {}

		class Item extends entities.Entity
			constructor: (opts) ->
				super _.extend {
					width: 23
					layer: 150
					type: "item"
					centered: true
				}, opts

			showDisplay: ->
				console.log "showing display"

			hideDisplay: ->
				console.log "hiding display"

		class Gun extends Item
			constructor: (@model) ->
				super
					graphic: new gunSprites.GunSprite @model.model
					mixins:
						updates: [
							@model
						]

			equip: (entity) ->
				if entity.gun?
					oldGun		= new Gun entity.gun
					oldGun.x	= entity.x
					oldGun.y	= entity.y
					@scene.add oldGun
				@scene.remove this
				entity.gun = @model

		getItemClass = multimethod()
				.dispatch (i) ->
					i.constructor
				.when guns.GunModel, -> Gun

		ns.for = (i) ->
			new (getItemClass i) i

		return ns
