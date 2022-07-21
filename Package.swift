// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MQClient",
    products: [
        .library(name: "MQClient",targets: ["MQClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server-community/mqtt-nio.git", from: "2.4.0"),
    ],
    targets: [
        .target(
            name: "MQClient",
            dependencies: [
                .product(name: "MQTTNIO", package: "mqtt-nio")
            ]),
        .testTarget(
            name: "MQClientTests",
            dependencies: ["MQClient"]),
    ]
)
