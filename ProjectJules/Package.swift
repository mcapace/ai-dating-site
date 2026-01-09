// swift-tools-version: 5.9
// Package.swift for Project Jules
// Note: This is for reference. Xcode uses Swift Package Manager integration through the UI.

import PackageDescription

let package = Package(
    name: "ProjectJules",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ProjectJules",
            targets: ["ProjectJules"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0"),
        .package(url: "https://github.com/airbnb/lottie-spm", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "ProjectJules",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "Lottie", package: "lottie-spm"),
            ]
        ),
    ]
)

