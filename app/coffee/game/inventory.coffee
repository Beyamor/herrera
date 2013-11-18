define ['game/guns'],
	(guns) ->
		ns = {}

		equip = multimethod()
			.dispatch (item) ->
				item.constructor
			.when guns.GunModel, (gun) ->
				@gun = gun

		class ns.Inventory
			constructor: (@capacity) ->
				@items = []

			add: (item) ->
				throw new Error "Inventory is full" if @isFull
				@items.push item

			update: ->
				@gun.update() if @gun?

			equip: equip
			
			addAndEquip: (item) ->
				@add item
				@equip item

			@accessors
				isFull:
					get: -> @items.length >= @capacity
			

		return ns
