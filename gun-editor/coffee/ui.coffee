define ->
	ns = {}

	ns.button = (label, onClick) ->
		$('<button type="button">')
			.text(label)
			.click(onClick)

	return ns
