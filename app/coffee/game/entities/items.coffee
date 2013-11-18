define ['core/entities', "game/guns",'game/guns/sprites', 'game/entities/items/displays'],
	(entities, guns, gunSprites, displays) ->
		ns = {}

		Entity = entities.Entity

		class ns.ItemDisplay extends Entity
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

		class ns.Item extends Entity
			constructor: (opts) ->
				super _.extend {
					width: 24
					centered: true
					layer: 150
					type: "item"
				}, opts

			showDisplay: (entity) ->
				return if @isShowingDisplay
				@isShowingDisplay = true

				@display = new ns.ItemDisplay @x, @y, @createDisplay(entity)
				@scene.add @display
				@display.show()

			hideDisplay: ->
				return unless @isShowingDisplay
				@isShowingDisplay = false

				@display.hide()
				@scene.remove @display
				@display = null

		class Gun extends ns.Item
			constructor: (@model) ->
				super
					graphic: new gunSprites.GunSprite @model.model
					mixins:
						updates: [
							@model
						]

			createDisplay: (entity) ->
				new displays.GunDisplay @scene.hud, @model, entity.inventory.gun

			equip: (inventory) ->
				inventory.gun = @model

		getItemClass = multimethod()
				.dispatch (i) ->
					i.constructor
				.when guns.GunModel, -> Gun

		ns.for = (i) ->
			new (getItemClass i) i

		return ns
