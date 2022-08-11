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
        .package(url: "https://github.com/swift-server-community/mqtt-nio.git", exact: "2.5.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.14.0"),
        .package(url: "https://github.com/apple/swift-nio-transport-services.git", from: "1.6.0"),
        .package(url: "https://github.com/songtao046/CryptoSwift", .upToNextMajor(from: "1.0.1")),
        .package(url: "https://github.com/soyersoyer/SwCrypt", .upToNextMajor(from: "5.1.4")),
        .package(url: "https://github.com/songtao046/SwiftyRSA", from: "1.0.0"),
        
    ],
    targets: [
        .target(
            name: "MQClient",
            dependencies: [
                .product(name: "MQTTNIO", package: "mqtt-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "CryptoSwift", package: "CryptoSwift"),
                .product(name: "NIOTransportServices", package: "swift-nio-transport-services"),
                .product(name: "SwCrypt", package: "SwCrypt"),
                .product(name: "SwiftyRSA", package: "SwiftyRSA")
            ]
        ),
        .testTarget(
            name: "MQClientTests",
            dependencies: ["MQClient"]),
    ]
)
