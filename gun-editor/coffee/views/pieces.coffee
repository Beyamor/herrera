define ->
	ns = {}

	ns.PiecesBrowser = Backbone.View.extend
		events:
			"change .wiggle": "wiggleChanged"
			"change .name": "nameChanged"

		wiggleChanged: (e) ->
			el	= e.target
			data	= el.dataset
			vertex	= @model.vertices[data.vertex]

			vertex.wiggle[data.direction] = parseInt el.value

		nameChanged: (e) ->
			el	= e.target
			data	= el.dataset
			vertex	= @model.vertices[data.vertex]

			vertex.name = el.value

		template: _.template($('#piece-browser-template').html())

		render: ->
			@$el.html @template @model

			return this


	return ns
