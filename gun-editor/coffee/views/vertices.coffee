define ->
	ns = {}

	ns.VertexBrowser = Backbone.View.extend
		template: _.template($('#vertex-browser-template').html())

		render: ->
			@$el.html @template @model.toJSON()

			return this


	return ns
