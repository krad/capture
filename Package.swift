// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "capture",
    dependencies: [
      .package(url: "https://www.github.com/krad/Buffie", from: "0.9.0"),
    ],
    targets: [
        .target(
            name: "capture",
            dependencies: ["Buffie", "captureCore"]),
        .target(
            name: "captureCore",
            dependencies: ["Buffie"]),
        .testTarget(name: "captureTests", dependencies: ["captureCore"]),
    ]
)
