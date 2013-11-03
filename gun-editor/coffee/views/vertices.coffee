define ->
	ns = {}

	ns.VertexBrowser = Backbone.View.extend
		events:
			"change .wiggle": "wiggleChanged"

		initialize: ->
			for modelEvent in ['piece-added', 'piece-removed']
				@model.on modelEvent, => @render()

		wiggleChanged: (e) ->
			el	= e.target
			data	= el.dataset
			piece	= @model.get('pieces')[data.piece]
			vertex	= piece.vertices[data.vertex]

			vertex.wiggle[data.direction] = parseInt el.value

		template: _.template($('#vertex-browser-template').html())

		render: ->
			@$el.html @template @model.toJSON()

			return this


	return ns
