importScripts '/app/js/require.js'

pendingLayout = null
self.onmessage = (event) ->
	pendingLayout = event.data

require {
		urlArgs: 'bust=' + (new Date()).getTime(),
		baseUrl: '/app/js/',
	},
	['game/levels'],
	(levels) =>
		if pendingLayout?
			postMessage(levels.construct pendingLayout)
		else
			self.onmessage = (event) =>
				layout = event.data
				postMessage(levels.construct layout)
