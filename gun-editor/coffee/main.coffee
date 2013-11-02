define ['editor/models', 'editor/views', 'editor/views/variants', 'editor/views/renders'], (models, views, vv, renders) ->
	gun = new models.Gun {
		parts: [{
			name: "body",
			variants: [{
				name: "v0",
				pieces: [
				]
			}, {
				name: "v1",
				pieces: [
				]
			}]
		}, {
			name: "barrel",
			variants: [{
				name: "v0",
				pieces: [
				]
			}]
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

	gun.set 'selectedVariant', gun.get('parts').at(0).get('variants').at(0)
