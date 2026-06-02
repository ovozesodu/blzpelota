// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "BLZPelotaSignalKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "BLZPelotaSignalKit",
            targets: ["BLZPelotaSignalKit"]
        )
    ],
    targets: [
        .target(name: "BLZPelotaSignalKit")
    ]
)
