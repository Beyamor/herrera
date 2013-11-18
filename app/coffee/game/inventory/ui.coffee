define ['core/input'],
	(input) ->
		ns = {}

		class ns.InventoryDisplay
			constructor: (@inventory) ->
				@$el = $('<div>')
					.attr('class', 'inventory')
					.text('Inventory')

			update: ->
				@scene.removeWindow(this) if input.pressed 'close'

		return ns
