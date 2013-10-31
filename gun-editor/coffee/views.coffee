define ->
	ns = {}

	ns.PartsBrowser = Backbone.View.extend
		el: "#parts-browser"

		template: _.template($('#parts-browser-template').html())

		render: ->
			@$el.html @template parts: @model

			return this

	return ns
