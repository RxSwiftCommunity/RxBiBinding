// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "RxBiBinding",
	platforms: [
		.macOS(.v10_10), .iOS(.v10)
	],
    products: [
        .library(
            name: "RxBiBinding",
            targets: ["RxBiBinding"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.0.0" )
    ],
    targets: [
        .target(
            name: "RxBiBinding",
            dependencies: ["RxSwift", "RxCocoa"],
			path: "RxBiBinding"
        )
    ]
)
