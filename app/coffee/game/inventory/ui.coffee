define ['core/app', 'core/input', 'core/util'],
	(app, input, util) ->
		ns = {}

		random = util.random

		class ns.InventoryDisplay
			blocks: true

			constructor: (@owner, @inventory) ->
				@$el = $('<div>')
					.addClass('inventory')
					.html(app.templates.compile 'inventory-window', inventory)
				$('.equip-box', @$el).append app.assets.get 'player-sprite'

				dropZones = =>
					$('.drop-zone', @$el)

				dropZones()
					.droppable(
						drop: (event, ui) =>
							el	= $(ui.draggable)
							index	= el.data("item")
							item	= inventory.items[index]
							inventory.remove item

							angle	= random.angle()
							item.x	= @owner.x + 10 * Math.cos angle
							item.y	= @owner.y + 10 * Math.sin angle
							@scene.add item

							dropZones().removeClass 'highlight'
							@rerenderItems()

						over: =>
							dropZones().addClass 'highlight'

						out: =>
							dropZones().removeClass 'highlight'
					)

				$('.equip-box', @$el)
					.droppable(
						drop: (event, ui) =>
							index	= $(ui.draggable).data("item")
							item	= inventory.items[index]
							item.equip inventory
							@rerenderItems()

						hoverClass: 'highlight'
					)

				$('.close', @$el).click => @scene.removeWindow this

				@rerenderItems()

			rerenderItems: ->
				items = $('.items', @$el)
				items.empty()
				for index in [0...@inventory.items.length]
					do (index) =>
						el = $(app.templates.compile 'inventory-item',
							item: @inventory.items[index]
							index: index
						)

						$('.description', el).draggable(
							revert: true
							revertDuration: 50
							start: -> $('.equipped', el.parent()).hide()
							stop: ->
								$('.equipped', el.parent()).show()
						)

						items.append el

			update: ->
				@scene.removeWindow(this) if input.pressed('close') or input.pressed('inventory')

		return ns
