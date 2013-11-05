define ['editor/models', 'editor/views', 'editor/views/variants', 'editor/views/renders'],
	(models, views, vv, renders) ->
		gun = new models.Gun {
			parts: [{
				name: "body",
				variants: []
			}, {
				name: "barrel",
				variants: []
			}]
		}, parse: true

		partsBrowser = new views.PartsBrowser model: gun
		partsBrowser.render()

		piecesToolbar = new views.PiecesToolbar model: gun
		piecesToolbar.render()

		renderer = new renders.Renderer model: gun

		gun.on 'change:selectedVariant', ->
			$variantViewerContainer = $ '#variant-viewer'
			$variantViewerContainer.empty()

			selectedVariant = gun.get 'selectedVariant'
			return unless selectedVariant

			variantViewer = new vv.VariantViewer model: selectedVariant
			variantViewer.render()
			$variantViewerContainer.append variantViewer.$el

		$('#save').click ->
			data = gun.toJSON()

			$.ajax
				url: "http://localhost:9000"
				type: "POST"
				data:
					data: JSON.stringify(data)
				success: ->
					console.log "saved"
