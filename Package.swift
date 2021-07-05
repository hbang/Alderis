// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "Alderis",
	platforms: [
		.iOS(.v11)
	],
	products: [
		.library(name: "Alderis", targets: ["Alderis"]),
	],
	targets: [
		.target(name: "Alderis",
                path: "Alderis",
                resources: [
                    .process("Resources")
                ]
        )
	]
)
