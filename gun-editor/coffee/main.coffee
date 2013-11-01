define ['editor/models', 'editor/views', 'editor/views/variants'], (models, views, vv) ->
	gun = new models.Gun {
		parts: [{
			name: "body",
			variants: [
				name: "v0",
				pieces: [
				]
			]
		}]
	}, parse: true

	partsBrowser = new views.PartsBrowser model: gun
	partsBrowser.render()

	piecesToolbar = new views.PiecesToolbar model: gun
	piecesToolbar.render()

	gun.on 'change:selectedVariant', ->
		$variantViewerContainer = $ '#variant-viewer'
		$variantViewerContainer.empty()

		selectedVariant = gun.get 'selectedVariant'
		return unless selectedVariant

		variantViewer = new vv.VariantViewer model: selectedVariant
		variantViewer.render()

		$variantViewerContainer.append variantViewer.$el

	gun.set 'selectedVariant', gun.get('parts').at(0).get('variants').at(0)
