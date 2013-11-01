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

	ns.Variant = Backbone.Model.extend()

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
