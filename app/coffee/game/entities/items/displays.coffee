define ['core/app', 'core/graphics'],
	(app, gfx) ->
		ns = {}

		class ns.GunDisplay
			@properties: [{
				name:	"damage"
				label:	"Damage"
				type:	"int"
				better:	"higher"
			}, {
				name:	"maxCapacity"
				label:	"Capacity"
				type:	"int"
				better:	"higher"
			}, {
				name:	"firingRate"
				label:	"Firing rate"
				type:	"float"
				better:	"higher"
			}, {
				name:	"rechargeDelay"
				label:	"Recharge delay"
				type:	"float"
				better:	"lower"
			}, {
				name:	"rechargeSpeed"
				label:	"Recharge speed"
				type:	"float"
				better:	"higher"
			}]

			constructor: (@hud, @gun, @prevGun) ->

			show: ->
				@$el = $ '<div class="item-display gun-display">'
				for i in [0...ns.GunDisplay.properties.length]
					property	= ns.GunDisplay.properties[i]
					value		= @gun[property.name]
					prevValue	= if @prevGun then @prevGun[property.name]

					displayValue = (v) ->
						switch property.type
							when "int" then v.toFixed()
							when "float" then v.toFixed(2)

					comparision =
						if @prevGun
							if value == prevValue
								"same"
							else
								if property.better is "higher"
									if value > prevValue
										"better"
									else
										"worse"
								else
									if value < prevValue
										"better"
									else
										"worse"
						else
							"better"

					difference =
						if prevValue?
							value - prevValue
						else
							value

					differenceDisplay =
						if difference is 0
							""
						else
							if difference > 0
								" (+#{displayValue difference})"
							else
								" (#{displayValue difference})"

					$description = $('<div class="description">')
							.text("#{property.label}: ")
							.append($("<span>")
								.text("#{displayValue value}#{differenceDisplay}")
								.attr('class', "#{comparision} comparison"))
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
