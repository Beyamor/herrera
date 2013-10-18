define ['core/app'], (app) ->
	class Entity
		constructor: (x=0, y=0, @graphic=null) ->
			@pos	= {x: x, y: y}
			@vel	= {x: 0, y: 0}
			@layer	= 0
			@width	= 0
			@height	= 0
			@offset	= {x: 0, y: 0}

		center: ->
			@offset.x = -@width * 0.5
			@offset.y = -@height * 0.5

		update: ->
			@pos.x += @vel.x * app.elapsed
			@pos.y += @vel.y * app.elapsed

		render: ->
			return unless @graphic

			@graphic.render app.canvas, @pos

	return {
		Entity: Entity
	}
