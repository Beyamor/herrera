define ['core/util', 'editor/shapes'], (util, shapes) ->
	ns = {}

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

		addPiece: (piece) ->
			@get('pieces').push piece

		removePiece: (piece) ->
			vertex.unpin() for vertex in piece.vertices
			@get('pieces').remove piece

		createPin: (v1, v2) ->
			pin = new shapes.Pin this
			pin.add v1
			pin.add v2
			@get('pins').push pin

	ns.Variants = Backbone.Collection.extend
		model: ns.Variant

	ns.Part = Backbone.Model.extend
		embedded:
			variants: ns.Variants

		parse: parseForNesteds

	ns.Parts = Backbone.Collection.extend
		model: ns.Part

	ns.Gun = Backbone.Model.extend
		embedded:
			parts: ns.Parts

		parse: parseForNesteds

	return ns
