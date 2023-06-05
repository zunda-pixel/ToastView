// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ToastView",
  platforms: [.iOS(.v16), .macOS(.v13)],
  products: [
    .library(
      name: "ToastView",
      targets: ["ToastView"]
    ),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "ToastView",
      dependencies: []
    ),
  ]
)
