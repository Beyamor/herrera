define ['core/util'], (util) ->
	random = util.random

	features = [{
		# hole
		canFill: (area) ->
			area.width >= 7 and area.height >= 7

		fill: (area) ->
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
	}, {
		# horizontal wall segment
		canFill: (area) ->
			area.height is 5 and area.width >= 5 and area.width <= 7

		fill: (area) ->
			for i in [1...area.width-1]
				area.set i, 2, "W"
	}, {
		# vertical wall segment
		canFill: (area) ->
			area.width is 5 and area.height >= 5 and area.height <= 7

		fill: (area) ->
			for j in [1...area.height-1]
				area.set 2, j, "W"
	}]

	return {
		canFill: (area) ->
			for feature in features
				return true if feature.canFill area
			return false

		fill: (area) ->
			applicableFeatures = []
			for feature in features
				applicableFeatures.push(feature) if feature.canFill area

			throw new Error("no applicable feature") if applicableFeatures.length is 0
			random.any(applicableFeatures).fill area
	}
