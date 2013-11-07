define ['core/util', 'core/app', 'core/canvas', 'game/guns/models', 'game/guns/smg-data'],
	(util, app, canvas, models, smgModel) ->
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
				return unless @player.gun
				gun = @player.gun.model

				@canvas.clear()
				context = @canvas.context

				width = Math.floor (100 / gun.maxCapacity)
				for i in [0...Math.floor(gun.capacity)]
					context.beginPath()
					context.rect 100 - (i + 1) * width, 0, width, 20
					context.fillStyle = "#FACB0F"
					context.fill()
					context.strokeStyle	= "black"
					context.stroke()

				@canvas.renderTo @hud, @hud.width - 100, 0

		return ns
