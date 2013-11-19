define ['core/entities', "game/guns",'game/guns/sprites'],
	(entities, guns, gunSprites) ->
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

			equip: (inventory) ->
				@isEquipped = true

			unequip: (inventory) ->
				@isEquipped = false

		return ns
