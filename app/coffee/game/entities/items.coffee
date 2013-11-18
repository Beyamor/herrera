define ['core/entities', "game/guns",'game/guns/sprites', 'game/entities/items/displays'],
	(entities, guns, gunSprites, displays) ->
		ns = {}

		Entity = entities.Entity

		class ItemDisplay extends Entity
			constructor: (x, y, graphic) ->
				super
					x: x
					y: y
					graphic: graphic
					centered: true
					layer: -50

			show: ->
				@graphic.show() if @graphic? and @graphic.show?

			hide: ->
				@graphic.hide() if @graphic? and @graphic.hide?

		class Item extends Entity
			constructor: (opts) ->
				super _.extend {
					width: 24
					centered: true
					layer: 150
					type: "item"
				}, opts

			showDisplay: (entity) ->
				@display = new ItemDisplay @x, @y, @createDisplay(entity)
				@scene.add @display
				@display.show()

			hideDisplay: ->
				@display.hide()
				@scene.remove @display
				@display = null

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

			createDisplay: (entity) ->
				new displays.GunDisplay @model, entity.gun

		getItemClass = multimethod()
				.dispatch (i) ->
					i.constructor
				.when guns.GunModel, -> Gun

		ns.for = (i) ->
			new (getItemClass i) i

		return ns
