define ['core/util'], (util) ->
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
		addEdge: ({from: from, to: to}) ->
			edges = @get 'edges'
			for edge in edges
				return if (edge.from is from and edge.to is to) or
						(edge.to is from and edge.from is to)

			edges.push {
				from: from
				to: to
			}

		removeEdge: (edge) ->
			@get('edges').remove edge

		addVertex: (pos) ->
			@get('vertices').push
				pos: pos
				name: "Dude, give this guy a name"

		removeVertex: (vertex) ->
			@get('vertices').remove vertex
			@set 'edges',
				(edge for edge in @get('edges') when edge.from isnt vertex and edge.to isnt vertex)

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
