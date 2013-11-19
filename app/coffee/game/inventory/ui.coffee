define ['core/input', 'core/util'],
	(input, util) ->
		ns = {}

		random = util.random

		class ns.InventoryDisplay
			constructor: (@owner, @inventory) ->
				@$el = $('<div>').addClass('inventory')

				dropZones = null
				for which in ["left", "right", "top", "bottom"]
					dropZone = $('<div>')
						.addClass('drop-zone')
						.addClass(which)
						.droppable(
							drop: (event, ui) =>
								item = $(ui.draggable).data("item")
								inventory.remove item

								angle = random.angle()
								item.x = @owner.x + 10 * Math.cos angle
								item.y = @owner.y + 10 * Math.sin angle
								@scene.add item

								@rerender()
								dropZones.removeClass 'highlight'

							over: =>
								dropZones.addClass 'highlight'

							out: =>
								dropZones.removeClass 'highlight'
						)
					@$el.append dropZone
				dropZones = $('.drop-zone', @$el)

				mainWindow = $('<div>')
					.addClass('main-window')
					.append(
						$('<h1>')
						.text("Inventory")
					)
				@$el.append mainWindow

				@items = $('<div>').addClass('items')
				mainWindow.append @items
				@rerender()

				mainWindow.append(
					$('<div>')
					.addClass('close')
					.text("X")
					.click(=> @scene.removeWindow this)
				)

			rerender: ->
				@items.empty()
				for item in @inventory.items
					do (item) =>
						itemEl = $('<div>').append(
								$('<span>')
								.addClass('description')
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
