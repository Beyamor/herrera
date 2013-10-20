define ['core/graphics', 'core/app', 'core/util'], (gfx, app, util) ->
	ns = {}

	realizeArg = (arg) ->
		if Array.isArray arg
			arg[0] + Math.random() * (arg[1] - arg[0])
		else
			arg

	class ns.Particle
		constructor: (args, @target, @camera) ->

			@pos = {x: args.x, y: args.y}

			@image = new gfx.Image args.image
			@image.centerOrigin()

			@elapsed = 0
			@lifespan = realizeArg args.lifespan

			if args.speed? and args.direction?
				direction = realizeArg args.direction
				if args.directionWiggle?
					direction += -args.directionWiggle + Math.random() * args.directionWiggle * 2

				speed = realizeArg args.speed

				@vel = {x: speed * Math.cos(direction), y: speed * Math.sin(direction)}

		update: ->
			@elapsed += app.elapsed

			if @vel
				@pos.x += @vel.x * app.elapsed
				@pos.y += @vel.y * app.elapsed

		render: ->
			@image.render @target, @pos, @camera

		@define 'isDead',
			get: -> @elapsed >= @lifespan

	class ns.Burst
		constructor: (@opts) ->
			@isFinished = true
			@x = @opts.x
			@y = @opts.y
			@particle = @opts.particle

		update: ->
			amount = @opts.amount or 1

			@opts.particle.x = @x
			@opts.particle.y = @y
			for i in [0...amount]
				@system.addParticle @particle

	class ns.Continuous
		constructor: (@opts) ->
			@x = @opts.x
			@y = @opts.y
			@particle = @opts.particle

		kill: ->
			@isFinished = true

		update: ->
			amount = @opts.amount or 1
			@opts.particle.x = @x
			@opts.particle.y = @y
			for i in [0...amount]
				@system.addParticle @particle

	class ns.ParticleSystem
		constructor: (@scene) ->
			@emitters	= []
			@particles	= []

		addEmitter: (opts) ->
			switch opts.type
				when "burst" then emitter = new ns.Burst opts
				when "continuous" then emitter = new ns.Continuous opts
				else throw new Error "Uknown emitter type #{opts.type}"
			emitter.system = this
			@emitters.push emitter
			return emitter

		addParticle: (particle) ->
			@particles.push new ns.Particle particle, app.canvas, @scene.camera

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
			particle.render() for particle in @particles

	return ns
