define ['core/graphics', 'core/app', 'core/util'], (gfx, app, util) ->
	ns = {}

	class ns.Particle
		constructor: ({x: x, y: y, image: image, lifespan: lifespan, \
				speed: speed, direction: direction, directionWiggle: directionWiggle}) ->

			@pos = {x: x, y: y}

			@image = new gfx.Image image
			@image.centerOrigin()

			@elapsed = 0

			@lifespan =
				if Array.isArray lifespan
					lifespan[0] + Math.random() * (lifespan[1] - lifespan[0])
				else
					lifespan

			if speed? and direction?
				if directionWiggle?
					direction += -directionWiggle + Math.random() * directionWiggle * 2

				speed =
					if Array.isArray speed
						speed[0] + Math.random() * (speed[1] - speed[0])
					else
						speed

				@vel = {x: speed * Math.cos(direction), y: speed * Math.sin(direction)}

		update: ->
			@elapsed += app.elapsed

			if @vel
				@pos.x += @vel.x * app.elapsed
				@pos.y += @vel.y * app.elapsed

		render: (target, camera) ->
			@image.render target, @pos, camera

		@define 'isDead',
			get: -> @elapsed >= @lifespan

	class ns.Burst
		constructor: (@opts) ->
			@isFinished = true

		update: ->
			amount = @opts.amount or 1

			@opts.particle.x = @opts.x
			@opts.particle.y = @opts.y
			for i in [0...amount]
				@system.addParticle @opts.particle

	class ns.ParticleSystem
		constructor: (@scene) ->
			@emitters	= []
			@particles	= []

		addEmitter: (opts) ->
			switch opts.type
				when "burst" then emitter = new ns.Burst opts
				else throw new Error "Uknown emitter type #{opts.type}"
			emitter.system = this
			@emitters.push emitter

		addParticle: (particle) ->
			@particles.push new ns.Particle particle

		update: ->
			emittersToRemove = []
			for emitter in @emitters
				emitter.update()
				emittersToRemove.push(emitter) if emitter.isFinished
			@emitters.remove(emitter) for emitter in emittersToRemove

			particlesToRemove = []
			for particle in @particles
				particle.update()
				particlesToRemove.push(particle) if particle.isDead
			@particles.remove(particle) for particle in particlesToRemove

		render: ->
			particle.render(app.canvas, @scene.camera) for particle in @particles

	return ns
