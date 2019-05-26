import PackageDescription

let package = Package(
    name: "RxBiBinding",
    products: [
        .library(
            name: "RxBiBinding",
            targets: ["RxBiBinding", "RxBiBinding macOS"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "4.5" )
    ],
    targets: [
        .target(
            name: "RxBiBinding",
            dependencies: ["RxSwift", "RxCocoa"]
        ),
        .target(
            name: "RxBiBinding macOS",
            dependencies: ["RxSwift", "RxCocoa"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
