define ['core/util', 'game/guns/shapes'], (util, shapes) ->
	ns = {}

	random = util.random

	# shout out to http://www.shesek.info/web-development/recursive-backbone-models-tojson
	Backbone.Model.prototype.toJSON = ->
		if (@_isSerializing)
			return this.id || this.cid
		@_isSerializing = true
		json = _.clone @attributes
		_.each(json, (value, name) ->
			if _.isFunction(value.toJSON)
				(json[name] = value.toJSON())
		)
		@_isSerializing = false
		return json

	# so to so: http://stackoverflow.com/questions/6535948/nested-models-in-backbone-js-how-to-approach
	parseForNesteds = (response) ->
		for key, embeddedClass of @embedded
			emdeddedData	= response[key]
			response[key]	= new embeddedClass emdeddedData, parse: true

		return response

	ns.Variant = Backbone.Model.extend
		defaults: ->
			pins: []
			pieces: []

		addPiece: (piece) ->
			@get('pieces').push piece
			@trigger "piece-added"

		removePiece: (piece) ->
			vertex.unpin() for vertex in piece.vertices
			@get('pieces').remove piece
			@trigger "piece-removed"

		createPin: (v1, v2) ->
			pin = new shapes.Pin this
			pin.add v1
			pin.add v2
			@get('pins').push pin

		realize: ->
			realizedPieces = []

			for piece in @get 'pieces'
				piece.saveVertices()

			for piece in @get 'pieces'
				piece.wiggle()

			for piece in @get 'pieces'
				realizedPieces.push piece.renderData()

			for piece in @get 'pieces'
				piece.restoreVertices()

			return {
				pieces: realizedPieces
				getNamedVertex: (name) ->
					for piece in @pieces
						for vertex in piece.vertices
							return vertex if vertex.name is name
					throw new Error "Unknown vertex #{name}"
			}

		toJSON: ->
			pieces = (piece.toJSON() for piece in @get 'pieces')

			pins = []
			for pin in @get 'pins'
				pinData = []
				for vertex in pin.vertices
					pinData.push {
						piece: @get('pieces').indexOf vertex.shape
						vertex: vertex.shape.vertices.indexOf vertex
					}
				pins.push pinData

			return {
				pieces:		pieces
				pins:		pins
			}

		parse: (response) ->
			pieces = []
			for pieceData in response.pieces
				pieceClass = switch pieceData.shape
					when "triangle"		then shapes.Triangle
					when "quad"		then shapes.Quad
					when "rectangle"	then shapes.Rectangle

				piece = new pieceClass this, pieceData
				pieces.push piece
			response.pieces = pieces

			pins = []
			for pinData in response.pins
				pin = new shapes.Pin this

				for {piece: pieceIndex, vertex: vertexIndex} in pinData
					vertex = pieces[pieceIndex].vertices[vertexIndex]
					pin.add vertex

				pins.push pin
			response.pins = pins

			return response

	ns.Variants = Backbone.Collection.extend
		model: ns.Variant

	ns.Part = Backbone.Model.extend
		embedded:
			variants: ns.Variants

		parse: parseForNesteds

		getAny: ->
			variants = @get('variants')
			throw new Error "No variants for #{@get 'name'}" if variants.length is 0

			index = random.intInRange 0, variants.length
			return variants.at index

	ns.Parts = Backbone.Collection.extend
		model: ns.Part

	ns.Gun = Backbone.Model.extend
		url: "http://localhost:9000"

		embedded:
			parts: ns.Parts

		parse: (response) ->
			response = parseForNesteds.call this, response
			delete response['selectedVariant']
			return response

		getPart: (name) ->
			@get('parts').where({name: name})[0]

		realize: ->
			body	= @getPart('body').getAny().realize()
			barrel	= @getPart('barrel').getAny().realize()

			barrelVertex	= body.getNamedVertex "barrel"
			bodyVertex	= barrel.getNamedVertex "body"

			dx = barrelVertex.x - bodyVertex.x
			dy = barrelVertex.y - bodyVertex.y

			for piece in barrel.pieces
				for vertex in piece.vertices
					vertex.x += dx
					vertex.y += dy

				for [v1, v2] in piece.visibleEdges
					v1.x += dx
					v1.y += dy
					v2.x += dx
					v2.y += dy

			paintColor = random.any [
				"#5A5F6E",
				"#BA2525",
				"#BA8B25",
				"#49853E",
				"#B89AA6",
				"#7A442F",
				"#0A010D",
				"#D5DBF5"
			]

			metalColor = random.any [
				"#848687",
				"#B8BDBF"
			]

			return {
				paint: paintColor
				metal: metalColor
				parts: [
					barrel,
					body
				]
			}

	return ns
