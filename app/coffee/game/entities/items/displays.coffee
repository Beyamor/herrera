define ['core/graphics'],
	(gfx) ->
		ns = {}

		class ns.GunDisplay extends gfx.StandardGraphic
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
				super
					width: 250
					height: ns.GunDisplay.properties.length * 20

			draw: (context) ->
				context.font		= "16px Sans-serif"
				context.strokeStyle	= "black"
				context.lineWidth	= 3

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

					description = "#{property.label}: #{displayValue value}#{differenceDisplay}"

					context.fillStyle =
						switch comparision
							when "better" then "green"
							when "same" then "white"
							when "worse" then "red"

					context.strokeText	description, 5, (i + 1) * 20 - 5
					context.fillText	description, 5, (i + 1) * 20 - 5

		return ns
