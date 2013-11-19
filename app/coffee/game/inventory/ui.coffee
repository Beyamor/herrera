define ['core/input', 'core/util'],
	(input, util) ->
		ns = {}

		random = util.random

		class ns.InventoryDisplay
			constructor: (@owner, @inventory) ->
				@$el = $('<div>').attr('class', 'inventory')

				dropZone = $('<div>')
					.attr('class', 'drop-zone')
					.droppable(
						drop: (event, ui) =>
							item = $(ui.draggable).data("item")
							inventory.remove item

							angle = random.angle()
							item.x = @owner.x + 10 * Math.cos angle
							item.y = @owner.y + 10 * Math.sin angle
							@scene.add item

							@rerender()
					)
				@$el.append dropZone

				mainWindow = $('<div>')
					.attr('class', 'main-window')
					.append(
						$('<h1>')
						.text("Inventory")
					).droppable(
						over: (event) =>
							dropZone.droppable "disable"
						out: (event) =>
							dropZone.droppable "enable"
					)
				@$el.append mainWindow

				@items = $('<div>').attr('class', 'items')
				mainWindow.append @items
				@rerender()

				mainWindow.append(
					$('<div>')
					.attr('class', 'close')
					.text("X")
					.click(=> @scene.removeWindow this)
				)

			rerender: ->
				@items.empty()
				for item in @inventory.items
					do (item) =>
						itemEl = $('<div>').append(
								$('<span>')
								.attr('class', 'description')
								.text(item.description)
								.draggable(
									revert: true
									revertDuration: 50
								)
								.data("item", item)
							)
						itemEl.item = item
						@items.append itemEl


			update: ->
				@scene.removeWindow(this) if input.pressed('close') or input.pressed('inventory')

		return ns
