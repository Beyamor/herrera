define ['core/util', 'core/app', 'game/guns/models',
	'game/items', 'game/guns/sprites',
	'game/guns/smg-data'],
	(util, app, models, \
	items, sprites, \
	smgModel) ->
		ns = {}

		random = util.random

		SMG_MODEL = new models.Gun smgModel, parse: true

		class ns.Gun extends items.Item
			constructor: ({capacity: @maxCapacity, firingRate: @firingRate, \
					rechargeDelay: @rechargeDelay, rechargeSpeed: @rechargeSpeed, \
					damage: @damage}) ->

						super
							graphic: new sprites.GunSprite SMG_MODEL.realize()

						@capacity	= @maxCapacity
						@isRecharging	= false
						@canShoot	= true

						@rechargeTimer	= new util.Timer {
							period: @rechargeDelay,
							callback: =>
								@isRecharging = true
						}

						@shotTimer = new util.Timer {
							period: (1 / @firingRate)
							callback: =>
								@canShoot = true
						}

						@description = "Gun"

			update: ->
				super()
				if @isRecharging
					@capacity += app.elapsed * @rechargeSpeed
					if @capacity >= @maxCapacity
						@capacity = @maxCapacity
						@isRecharging = false

				@rechargeTimer.update()
				@shotTimer.update()

			tryShooting: ->
				return false if (@capacity < 1) or not @canShoot

				@capacity -= 1

				@isRecharging = false
				@rechargeTimer.restart()

				@canShoot = false
				@shotTimer.restart()

				return true

			equip: (inventory) ->
				for item in inventory.items
					if item instanceof ns.Gun and item.isEquipped
						item.unequip inventory

				inventory.gun = this
				super inventory

			unequip: (inventory) ->
				super inventory
				inventory.gun = null

		ns.createRandom = ->
			new ns.Gun {
				capacity: random.intInRange 10, 20
				firingRate: random.inRange 3, 8
				rechargeDelay: 0.5
				rechargeSpeed: random.inRange 0.5, 10
				damage: random.any [5, 5, 5, 6, 6, 7, 7, 8]
			}

		comparableProperties = [{
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

		# g1 as compared to g2
		ns.compare = (g1, g2) ->
			for property in comparableProperties
				v1	= if g1? then g1[property.name] else 0
				v2	= if g2? then g2[property.name] else 0

				difference = v1 - v2

				comparison =
					if g2?
						if v1 == v2
							"same"
						else
							if property.better is "higher"
								if v1 > v2
									"better"
								else
									"worse"
							else
								if v1 < v2
									"better"
								else
									"worse"
					else
						if g1?
							"better"
						else
							"same"

				{
					label:		property.label
					type:		property.type
					value:		v1
					difference:	difference
					comparison:	comparison
				}
		return ns
