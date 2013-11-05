define ['core/util', 'editor/shapes'], (util, shapes) ->
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
				realizedPieces.push piece.toJSON()

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

			return {
				pieces: pieces
			}

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
		embedded:
			parts: ns.Parts

		parse: parseForNesteds

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

			return [
				barrel,
				body
			]

	return ns
