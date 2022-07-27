// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MQClient",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v12), .watchOS(.v6)],
    products: [
        .library(name: "MQClient",targets: ["MQClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server-community/mqtt-nio.git", exact: "2.5.2"),
        .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0" ..< "3.0.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.14.0"),
        .package(url: "https://github.com/apple/swift-nio-transport-services.git", from: "1.6.0"),
    ],
    targets: [
        .target(
            name: "MQClient",
            dependencies: [
                .product(name: "MQTTNIO", package: "mqtt-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "_CryptoExtras", package: "swift-crypto"),
                .product(name: "NIOTransportServices", package: "swift-nio-transport-services"),
            ]
        ),
        .testTarget(
            name: "MQClientTests",
            dependencies: ["MQClient"]),
    ]
)
