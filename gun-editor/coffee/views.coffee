define ['editor/shapes'], (shapes) ->
	ns = {}

	ns.PartsBrowser = Backbone.View.extend
		el: "#parts-browser"

		events:
			"click .variant": "selectVariant"

		selectVariant: (e) ->
			data	= e.toElement.dataset
			part	= data.part
			variant	= data.variant

			selectedVariant = @model.get("parts").at(part).get("variants").at(variant)

			@model.set "selectedVariant", selectedVariant

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

					selectedVariant.addPiece new piece selectedVariant

			@$el.append(
					button "Triangle", addPiece shapes.Triangle
					button "Quad", addPiece shapes.Quad
					button "Rectangle", addPiece shapes.Rectangle
			)

	return ns
