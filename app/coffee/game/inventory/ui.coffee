define ['core/app', 'core/input', 'core/util'],
	(app, input, util) ->
		ns = {}

		random = util.random

		class ns.InventoryDisplay
			blocks: true

			constructor: (@owner, inventory) ->
				@$el = $('<div>')
					.addClass('inventory')
					.html(app.templates.compile 'inventory-window', inventory)
				$('.equip-box', @$el).append app.assets.get 'player-sprite'

				refreshEquipState = =>
					$('.item .description', @$el).each ->
						index		= $(this).data('item')
						item		= inventory.atIndex index
						equipped	= $('.equipped', $(this).parent())

						if item.isEquipped
							equipped.show()
						else
							equipped.hide()
				refreshEquipState()

				$('.item .description', @$el)
					.draggable(
						revert: true
						revertDuration: 50
						start: -> $('.equipped', $(this).parent()).hide()
						stop: ->
							$('.equipped', $(this).parent()).show()
							refreshEquipState()
					)

				dropZones = =>
					$('.drop-zone', @$el)

				dropZones()
					.droppable(
						drop: (event, ui) =>
							el	= $(ui.draggable)
							index	= el.data("item")
							item	= inventory.atIndex index
							inventory.remove item
							el.parent().remove()

							angle	= random.angle()
							item.x	= @owner.x + 10 * Math.cos angle
							item.y	= @owner.y + 10 * Math.sin angle
							@scene.add item

							dropZones().removeClass 'highlight'

						over: =>
							dropZones().addClass 'highlight'

						out: =>
							dropZones().removeClass 'highlight'
					)

				$('.equip-box', @$el)
					.droppable(
						drop: (event, ui) =>
							index	= $(ui.draggable).data("item")
							item	= inventory.atIndex index
							item.equip inventory
							refreshEquipState()

						hoverClass: 'highlight'
					)

			update: ->
				@scene.removeWindow(this) if input.pressed('close') or input.pressed('inventory')

		return ns
