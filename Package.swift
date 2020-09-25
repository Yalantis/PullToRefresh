// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "PullToRefresh",
    platforms: [
        .iOS(.v8),
    ],
    products: [
        .library(name: "PullToRefresh", targets: ["PullToRefresh"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "PullToRefresh",
            dependencies: [
            ],
            path: "PullToRefresh"
        )
    ],
    swiftLanguageVersions: [ .v5 ]
)
