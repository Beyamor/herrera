define ['editor/views'], (views) ->
	parts = [{
		"name": "body",
		"variants": [
			"name": "v0",
			"vertices": [{
				"name": "a",
				"pos": {
					"x": -5,
					"y": 0
				}
			}, {
				"name": "b",
				"pos": {
					"x": 5,
					"y": 0
				}
			}]
		]
	}]

	partsBroswer = new views.PartsBrowser model: parts
	partsBroswer.render()
