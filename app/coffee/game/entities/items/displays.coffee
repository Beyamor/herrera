define ['core/graphics'],
	(gfx) ->
		ns = {}

		class ns.GunDisplay extends gfx.StandardGraphic
			@properties: [{
				name:	"maxCapacity"
				label:	"Capacity"
				type:	"int"
			}, {
				name:	"firingRate"
				label:	"Firing rate"
				type:	"float"
			}, {
				name:	"rechargeDelay"
				label:	"Recharge delay"
				type:	"float"
			}, {
				name:	"rechargeSpeed"
				label:	"Recharge speed"
				type:	"float"
			}, {
				name:	"damage"
				label:	"Damage"
				type:	"int"
			}]

			constructor: (@gun) ->
				super
					width: 200
					height: ns.GunDisplay.properties.length * 20

			draw: (context) ->
				context.font		= "16px Sans-serif"
				context.fillStyle	= "white"
				context.strokeStyle	= "black"
				context.lineWidth	= 3

				for i in [0...ns.GunDisplay.properties.length]
					property	= ns.GunDisplay.properties[i]
					value		= @gun[property.name]
					valueDisplay	=
						switch property.type
							when "int" then value.toFixed()
							when "float" then value.toFixed(2)
					description	= "#{property.label}: #{valueDisplay}"

					context.strokeText	description, 5, (i + 1) * 20 - 5
					context.fillText	description, 5, (i + 1) * 20 - 5

		return ns
