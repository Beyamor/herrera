define ['core/input'],
	(input) ->
		ns = {}

		class ns.InventoryDisplay
			constructor: (@inventory) ->
				@$el = $('<div>')
					.attr('class', 'inventory')
					.text('Inventory')

				for item in @inventory.items
					@$el.append(
						$('<div>')
						.attr('class', 'description')
						.text(item.description)
					)

				@$el.append(
					$('<div>')
					.attr('class', 'close')
					.text("X")
					.click(=> @scene.removeWindow this)
				)

			update: ->
				@scene.removeWindow(this) if input.pressed('close') or input.pressed('inventory')

		return ns
