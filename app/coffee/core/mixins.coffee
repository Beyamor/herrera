define ['core/util'], (util) ->
	ns = {}

	mixins = {}

	ns.define = (name, mixin) ->
		throw new Error "Mixin #{name} already defined" if mixins[name]?

		mixins[name] = mixin

	ns.defineAll = (specs) ->
		ns.define(name, mixin) for name, mixin of specs

	ns.realize = (name, arg) ->
		mixin = mixins[name]
		throw new Error "Uknown mixin #{name}" unless mixin?

		mixin.call null, arg

	ns.realizeAll = (specs) ->
		ns.realize(name, arg) for name, arg of specs

	return ns
