importScripts '/app/js/require.js'

require {
		urlArgs: 'bust=' + (new Date()).getTime(),
		baseUrl: '/app/js/',
	},
	['game/levels'],
	(levels) ->
		postMessage 'Did it'
