define ['core/app', 'core/util'], (app, util) ->
	class Entity
		constructor: (x=0, y=0, @graphic=null) ->
			@pos	= {x: x, y: y}
			@vel	= {x: 0, y: 0}
			@layer	= 0
			@width	= 0
			@height	= 0
			@offset	= {x: 0, y: 0}
			@collisionHandlers = {}

		center: ->
			@offset.x = -@width * 0.5
			@offset.y = -@height * 0.5

		collide: (type, x, y) ->
			return null unless @scene
			prevX = @pos.x
			prevY = @pos.y
			@pos.x = x
			@pos.y = y

			result = @scene.collide this, type

			@pos.x = prevX
			@pos.y = prevY

			return result

		move: ->
			xSteps	= Math.floor(Math.abs(@vel.x * app.elapsed))
			xInc 	= util.sign(@vel.x)

			stop = false
			while xSteps > 0
				for type, handler of @collisionHandlers
					collision = @collide type, @pos.x + xInc, @pos.y
					if collision
						stop = handler(collision)
					break if stop

				break if stop
				@pos.x += xInc
				xSteps -= 1

			ySteps	= Math.floor(Math.abs(@vel.y * app.elapsed))
			yInc 	= util.sign(@vel.y)

			stop = false
			while ySteps > 0
				for type, handler of @collisionHandlers
					collision = @collide type, @pos.x, @pos.y + yInc
					if collision
						stop = handler(collision)
					break if stop

				break if stop
				@pos.y += yInc
				ySteps -= 1

		update: ->
			if @vel.x isnt 0 or @vel.y isnt 0
				@move()
			else
				for type, handler of @collisionHandlers
					collision = @collide type, @pos.x, @pos.y
					handler(collision) if collision
			
		render: ->
			return unless @graphic

			@graphic.render app.canvas, @pos, @scene.camera

		hasType: (type) ->
			@type? and @type is type

		@define 'left',
			get: -> @pos.x + @offset.x

		@define 'right',
			get: -> @left + @width

		@define 'top',
			get: -> @pos.y + @offset.y

		@define 'bottom',
			get: -> @top + @height

		@define 'x',
			get: -> @pos.x
			set: (x) -> @pos.x = x

		@define 'y',
			get: -> @pos.y
			set: (y) -> @pos.y = y

	return {
		Entity: Entity
	}
