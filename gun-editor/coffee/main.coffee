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

	variantViewer = new views.VariantViewer model: gun
	variantViewer.render()

	gun.set 'selectedVariant', gun.get('parts').at(0).get('variants').at(0)
