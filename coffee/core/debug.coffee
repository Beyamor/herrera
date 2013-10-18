define {
	log: (args...) ->
		return unless @enabled
		console.log args.join ', '

	logType: (type, args...) ->
		return unless @types and @types[type]
		@log.apply this, args

	config: (opts) ->
		for k, v of opts
			@[k] = v
}
