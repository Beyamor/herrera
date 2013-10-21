define ['core/util', 'core/app', 'core/canvas'],
	(util, app, canvas) ->
		ns = {}

		random = util.random

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
					capacity: random.intInRange 1, 20
					firingRate: random.inRange 0.1, 10
					rechargeDelay: 0.5
					rechargeSpeed: random.inRange 0.5, 3
				}

		class ns.AmmoDisplay
			constructor: (@hud, @player) ->
				@canvas = new canvas.Canvas {
					width: 100
					height: 20
					clearColor: 'black'
				}

				context = @canvas.context
				context.fillStyle = context.strokeStyle = "#FACB0F"
				context.lineWidth = 4

			render: ->
				gun = @player.gun.model
				return unless gun

				@canvas.clear()
				context = @canvas.context

				left = (1 - gun.capacity / gun.maxCapacity) * 100
				context.beginPath()
				context.moveTo left, 0
				context.lineTo 100, 0
				context.lineTo 100, 20
				context.lineTo left - 15, 20
				context.fill()

				context.beginPath()
				context.rect 0, 0, 100, 20
				context.stroke()

				@canvas.renderTo @hud, @hud.width - 100, 0

		return ns
