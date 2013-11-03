define ->
	ns = {}

	ns.VertexBrowser = Backbone.View.extend
		initialize: ->
			for modelEvent in ['piece-added', 'piece-removed']
				@model.on modelEvent, => @render()

		template: _.template($('#vertex-browser-template').html())

		render: ->
			@$el.html @template @model.toJSON()

			return this


	return ns
