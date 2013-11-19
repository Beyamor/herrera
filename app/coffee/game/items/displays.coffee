define ['core/app', 'core/entities', 'game/guns'],
	(app, entities, guns) ->
		ns = {}

		class GunDisplay
			constructor: (gun, prevGun) ->
				@comparision = guns.compare gun, prevGun

			show: (hud) ->
				@$el = $ '<div class="item-display gun-display">'
				for property in @comparision
					displayValue = (v) ->
						switch property.type
							when "int" then v.toFixed()
							when "float" then v.toFixed(2)

					differenceDisplay =
						if property.difference is 0
							""
						else
							if property.difference > 0
								" (+#{displayValue property.difference})"
							else
								" (#{displayValue property.difference})"

					$description = $('<div class="description">')
							.text("#{property.label}: ")
							.append($("<span>")
								.text("#{displayValue property.value}#{differenceDisplay}")
								.attr('class', "#{property.comparison} comparison"))

					@$el.append $description

				hud.append @$el

				@width	= @$el.outerWidth()
				@height	= @$el.outerHeight()

				@$el.hide()

			hide: ->
				return unless @$el?

				@$el.hide 100, =>
					@$el.remove()
					@$el = null

			render: (_, point, camera) ->
				return unless @$el?

				unless @$el.is(":visible")
					@$el.show 100

				@$el.offset
					left:	point.x - camera.x - @width/2
					top:	point.y - camera.y - @height/2

		class DisplayEntity extends entities.Entity
			constructor: (x, y, graphic) ->
				super
					x: x
					y: y
					graphic: graphic

			added: ->
				@graphic.show @scene.hud

			removed: ->
				@graphic.hide()


		createGraphic = multimethod()
				.dispatch (item, entity) ->
					item.constructor
				.when guns.Gun, (item, entity) ->
					new GunDisplay item, entity.inventory.gun

		ns.create = (item, entity) ->
			new DisplayEntity item.x, item.y, createGraphic(item, entity)

		return ns
