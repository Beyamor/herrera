define
	rooms: [
		definition: [
			["W", "o", "W", "W", "W", "W", "W", "W", "W", "W", "W", "W", "W", "W", "W", "W"],
			["o", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "o"],
			["W", ".", "W", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "W"],
			["W", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "W"],
			["W", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "W"],
			["W", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "W"],
			["W", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "W"],
			["W", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "W"],
			["W", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "W"],
			["W", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "W"],
			["W", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "W"],
			["W", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "W"],
			["W", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "W"],
			["W", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "W"],
			["W", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "W"],
			["W", "i", "W", "W", "W", "W", "W", "W", "W", "W", "W", "W", "W", "W", "W", "W"]
		],

		orientations: [{
			entrance: "south"
			exits: ["west", "north", "east"]
		}, {
			entrance: "west"
			exits: ["north", "east", "south"]
			transformation: {rotation: 90}
		}, {
			entrance: "north"
			exits: ["east", "south", "west"]
			transformation: {rotation: 180}
		}, {
			entrance: "east",
			exits: ["south", "west", "north"]
			transformation: {rotation: 90}
		}]
	]
