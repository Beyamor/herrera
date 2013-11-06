define ['editor/shapes', 'editor/ui', 'editor/models'], (shapes, ui, models) ->
	ns = {}

	ns.PartsBrowser = Backbone.View.extend
		el: "#parts-browser"

		events:
			"click .variant": "selectVariant"
			"click .new-part": "newVariant"

		initialize: ->
			@model.on 'change:parts', => @render()

		selectVariant: (e) ->
			data	= e.toElement.dataset
			part	= data.part
			variant	= data.variant

			selectedVariant = @model.get("parts").at(part).get("variants").at(variant)

			@model.set "selectedVariant", selectedVariant

		newVariant: (e) ->
			data		= e.target.dataset
			part		= @model.get("parts").at(data.part)
			newVariant	= new models.Variant

			part.get('variants').add(newVariant)
			@model.set 'selectedVariant', newVariant

			@render()

		template: _.template($('#parts-browser-template').html())

		render: ->
			@$el.html @template @model.toJSON()

			return this

	ns.PiecesToolbar = Backbone.View.extend
		el: "#pieces-toolbar"

		initialize: ->
			addPiece = (piece) =>
				=>
					selectedVariant = @model.get 'selectedVariant'
					return unless selectedVariant

					selectedVariant.addPiece new piece selectedVariant

			@$el.append(
					ui.button "Triangle", addPiece shapes.Triangle
					ui.button "Quad", addPiece shapes.Quad
					ui.button "Rectangle", addPiece shapes.Rectangle
			)

	return ns
