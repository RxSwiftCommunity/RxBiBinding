import PackageDescription

let package = Package(
    name: "RxBiBinding",
    products: [
        .library(
            name: "RxBiBinding",
            targets: ["RxBiBinding"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "4.2" )
    ],
    targets: [
        .target(
            name: "RxBiBinding",
            dependencies: ["RxSwift", "RxCocoa"]
        )
    ],
    swiftLanguageVersions: [.v4]
)
