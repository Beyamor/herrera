define ['core/app'], (app) ->
	class Entity
		constructor: (x=0, y=0, @graphic=null) ->
			@pos = {x: x, y: y}

		update: ->

		render: ->
			return unless @graphic

			@graphic.render app.canvas, @pos

	return {
		Entity: Entity
	}
