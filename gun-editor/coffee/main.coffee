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

	partsBroswer = new views.PartsBrowser model: gun
	partsBroswer.render()
