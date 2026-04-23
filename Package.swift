// swift-tools-version: 5.9
// -----------------------------------------------------------------------------
// Proje: tcknvkn-swift
// Dosya: Package.swift
// Açıklama: Swift Package Manager yapılandırmasını içerir.
// Oluşturma Tarihi: 2026-04-24
// Lisans: MIT
// Site: https://www.tcknvkn.com
// -----------------------------------------------------------------------------
import PackageDescription

let package = Package(
    name: "TcknVkn",
    products: [
        .library(name: "TcknVkn", targets: ["TcknVkn"])
    ],
    targets: [
        .target(
            name: "TcknVkn",
            path: "Sources/TcknVkn"
        ),
        .testTarget(
            name: "TcknVknTests",
            dependencies: ["TcknVkn"],
            path: "tests/TcknVknTests"
        )
    ]
)
