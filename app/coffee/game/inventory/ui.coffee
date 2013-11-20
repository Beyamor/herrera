define ['core/app', 'core/input', 'core/util'],
	(app, input, util) ->
		ns = {}

		random = util.random

		class ns.InventoryDisplay
			blocks: true

			constructor: (@owner, @inventory) ->
				@$el = $('<div>')
					.addClass('inventory')
				@rerender()

				$('.item .description', @$el)
					.draggable(
						revert: true
						revertDuration: 50
						start: -> $('.equipped', $(this).parent()).hide()
						stop: -> $('.equipped', $(this).parent()).show()
					)

				dropZones = =>
					$('.drop-zone', @$el)

				dropZones()
					.droppable(
						drop: (event, ui) =>
							index	= $(ui.draggable).data("item")
							item	= @inventory.atIndex index
							@inventory.remove item

							angle	= random.angle()
							item.x	= @owner.x + 10 * Math.cos angle
							item.y	= @owner.y + 10 * Math.sin angle
							@scene.add item

							@rerender()
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
							item	= @inventory.atIndex index
							item.equip inventory
							@rerender()

						hoverClass: 'highlight'
					)

				#dropZones = null
				#for which in ["left", "right", "top", "bottom"]
				#	dropZone = $('<div>')
				#		.addClass('drop-zone')
				#		.addClass(which)
				#		.droppable(
				#					#		)
				#	@$el.append dropZone
				#dropZones = $('.drop-zone', @$el)

				#mainWindow = $('<div>')
				#	.addClass('main-window')
				#	.append(
				#		$('<h1>')
				#		.text("Inventory")
				#	)
				#@$el.append mainWindow

				#playerImage = app.assets.get 'player-sprite'
				#equipBox = $('<div>')
				#		.addClass('equip-box')
				#		.append(playerImage)
				#		
				#mainWindow.append equipBox

				#@items = $('<div>').addClass('items')
				#mainWindow.append @items
				#@rerender()

				#mainWindow.append(
				#	$('<div>')
				#	.addClass('close')
				#	.text("X")
				#	.click(=> @scene.removeWindow this)
				#)

			rerender: ->
				@$el.html(app.templates.compile 'inventory-window', @inventory)
				$('.equip-box', @$el).append app.assets.get 'player-sprite'

				#@items.empty()
				#for item in @inventory.items
				#	do (item) =>
				#		itemEl = $('<div>').addClass('item')

				#		description = $('<span>')
				#				.addClass('description')
				#				.text(item.description)
				#				.draggable(
				#								#				)
				#				.data("item", item)
				#		itemEl.append description

				#		if item.isEquipped
				#			itemEl.append(
				#				$('<span>')
				#				.text('(equipped)')
				#				.addClass('equipped')
				#			)

				#		@items.append itemEl


			update: ->
				@scene.removeWindow(this) if input.pressed('close') or input.pressed('inventory')

		return ns
