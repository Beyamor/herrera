define ['game/entities/items'],
	(items) ->
		ns = {}

		class ns.Inventory
			constructor: (@capacity) ->
				@items = []

			add: (item) ->
				if item instanceof items.Item
					throw new Error "Inventory is full" if @isFull
					@items.push item
					item.scene.remove item if item.scene?
				else
					@add items.for item

			update: ->
				@gun.update() if @gun?

			addAndEquip: (item) ->
				@add item
				@items[@items.length-1].equip this

			@accessors
				isFull:
					get: -> @items.length >= @capacity
			

		return ns
