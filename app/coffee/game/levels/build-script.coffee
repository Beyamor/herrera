# Ugh, use relative URLs since the absolutes are different on different hosts
importScripts '../../require.js'

pendingLayout = null
self.onmessage = (event) ->
	pendingLayout = event.data

require {
		urlArgs: 'bust=' + (new Date()).getTime(),
		baseUrl: '../../',
	},
	['game/levels'],
	(levels) =>
		construct = (layout) =>
			postMessage(levels.construct layout)
			self.close()

		if pendingLayout?
			construct pendingLayout
		else
			self.onmessage = (event) =>
				construct event.data
