define ['core/util'], (util) ->
	random = util.random

	features = [{
		# hole
		canFill: (area) ->
			area.width >= 6 and area.height >= 6

		fill: (area) ->
			for i in [0...area.width]
				area.set i, 0, "."
				area.set i, 1, "."
				area.set i, area.height-1, "."
				area.set i, area.height-2, "."

			for j in [0...area.height]
				area.set 0, j, "."
				area.set 1, j, "."
				area.set area.width-1, j, "."
				area.set area.width-2, j, "."

			minX = 2
			maxX = area.width - 3
			minY = 2
			maxY = area.height - 3
			for i in [minX..maxX]
				for j in [minY..maxY]
					if i > minX and  i < maxX and j > minY and j < maxY
						area.set i, j, " "
					else
						area.set i, j, "W"
	}]

	return {
		canFill: (area) ->
			for feature in features
				return true if feature.canFill area
			return false

		fill: (area) ->
			applicableFeatures = []
			for feature in features
				applicableFeatures.push(feature) is feature.canFill area

			throw new Error("no applicable feature") if applicableFeatures.length is 0
			random.any(applicableFeatures).fill area
	}
