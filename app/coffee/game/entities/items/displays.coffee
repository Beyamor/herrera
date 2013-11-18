define ['core/app', 'core/graphics', 'game/guns'],
	(app, gfx, guns) ->
		ns = {}

		class ns.GunDisplay
			constructor: (@hud, gun, prevGun) ->
				@comparision = guns.compare gun, prevGun

			show: ->
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

				@hud.append @$el

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

		return ns
