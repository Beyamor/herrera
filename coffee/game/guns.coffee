define ['core/util', 'core/app'], (util, app) ->
	ns = {}

	class ns.Gun
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

		update: ->
			if @isRecharging
				@capacity += (app.elapsed / @rechargeSpeed) * @maxCapacity
				if @capacity >= @maxCapacity
					@capacity = @maxCapacity
					@isRecharging = false

			@rechargeTimer.update()

		tryShooting: ->
			console.log @capacity
			if @capacity <= 0
				return false

			@capacity -= 1

			@isRecharging = false
			@rechargeTimer.restart()

			@canShoot = false
			@shotTimer.restart()

			return true

	return ns
