define [],
	() ->
		ns = {}

		class ns.Inventory
			constructor: (@capacity) ->
				@items = []

			add: (item) ->
				throw new Error "Inventory is full" if @isFull
				@items.push item
				item.scene.remove item if item.scene?

			addAndEquip: (item) ->
				@add item
				@items[@items.length-1].equip this

			remove: (item) ->
				@items.remove item
				item.unequip(this) if item.isEquipped
				return item

			atIndex: (index) ->
				@items[index]

			update: ->
				@gun.update() if @gun?

			@accessors
				isFull:
					get: -> @items.length >= @capacity

		return ns
