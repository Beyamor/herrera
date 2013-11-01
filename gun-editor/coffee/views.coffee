define ['editor/shapes'], (shapes) ->
	ns = {}

	ns.PartsBrowser = Backbone.View.extend
		el: "#parts-browser"

		template: _.template($('#parts-browser-template').html())

		render: ->
			@$el.html @template @model.toJSON()

			return this

	button = (label, onClick) ->
		$('<button type="button">')
			.text(label)
			.click(onClick)

	ns.PiecesToolbar = Backbone.View.extend
		el: "#pieces-toolbar"

		initialize: ->
			addPiece = (piece) =>
				=>
					selectedVariant = @model.get 'selectedVariant'
					return unless selectedVariant

					selectedVariant.addPiece piece

			@$el.append(
					button "Rectangle", addPiece new shapes.Rectangle
			)

	return ns
