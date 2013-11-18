define ['core/graphics'],
	(gfx) ->
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

			constructor: (@gun, @prevGun) ->

			show: (hud) ->
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

					$description = $ '<div class="description">'
					$description.text "#{property.label}: #{displayValue value}#{differenceDisplay}"
					$description.attr 'class',
						switch comparision
							when "better" then "green"
							when "same" then "white"
							when "worse" then "red"
					@$el.append description
				hud.append @$el

			hide: ->
				return unless @$el

				@$el.remove()
				@$el = null

			render: (_, point, camera) ->
				#@$el.offset
				#	left:	point.x - camera.x - @$el.width()/2
				#	top:	point.y - camera.y - @$el.height()/2

		return ns
