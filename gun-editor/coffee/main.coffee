define ['editor/models', 'editor/views'], (models, views) ->
	gun = new models.Gun {
		parts: [{
			name: "body",
			variants: [
				name: "v0",
				vertices: [{
					name: "a",
					pos: {
						"x": -5,
						"y": 0
					}
				}, {
					name: "b",
					pos: {
						"x": 5,
						"y": 0
					}
				}]
			]
		}]
	}, parse: true

	partsBrowser = new views.PartsBrowser model: gun
	partsBrowser.render()

	gun.on 'change:selectedVariant', ->
		$variantViewerContainer = $ '#variant-viewer'
		$variantViewerContainer.empty()

		selectedVariant = gun.get 'selectedVariant'
		return unless selectedVariant

		variantViewer = new views.VariantViewer model: selectedVariant
		variantViewer.render()

		$variantViewerContainer.append variantViewer.$el

	gun.set 'selectedVariant', gun.get('parts').at(0).get('variants').at(0)
