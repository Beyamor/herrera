define ['core/util', 'core/app', 'game/guns/models', 'game/guns/smg-data'],
	(util, app, models, smgModel) ->
		ns = {}

		random = util.random

		SMG_MODEL = new models.Gun smgModel, parse: true

		class ns.GunModel
			constructor: ({capacity: @maxCapacity, firingRate: firingRate,\
					rechargeDelay: rechargeDelay, rechargeSpeed: @rechargeSpeed}) ->
						@capacity	= @maxCapacity
						@isRecharging	= false
						@canShoot	= true

						@rechargeTimer	= new util.Timer {
							period: rechargeDelay,
							callback: =>
								@isRecharging = true
						}

						@shotTimer = new util.Timer {
							period: (1 / firingRate)
							callback: =>
								@canShoot = true
						}

						@model = SMG_MODEL.realize()

			update: ->
				if @isRecharging
					@capacity += (app.elapsed / @rechargeSpeed) * @maxCapacity
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

			@createRandom: ->
				new ns.GunModel {
					capacity: random.intInRange 10, 20
					firingRate: random.inRange 5, 20
					rechargeDelay: 0.5
					rechargeSpeed: random.inRange 0.5, 3
				}
		
		return ns
