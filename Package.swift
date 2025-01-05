// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FFReadWriter",
    platforms: [.macOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FFReadWriter",
            type: .dynamic,
            targets: ["FFReadWriter"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FFReadWriter",
            path: "Sources",
            cSettings: [
                .headerSearchPath("FFReadWriter/ffmpeg-sdk-osx/include"),
                .headerSearchPath("FFReadWriter")
            ],
            swiftSettings: [
                .define("ENABLE_SOMETHING", .when(configuration: .release))
            ],
            linkerSettings: [
                .linkedFramework("AudioToolbox"),
                .linkedFramework("VideoToolbox"),
                .linkedFramework("CoreVideo"),
                .linkedFramework("CoreMedia"),
                .linkedFramework("Security"),
                .linkedLibrary("z"),
                .linkedLibrary("iconv"),
                .linkedLibrary("bz2"),
                .linkedLibrary("avcodec"),
                .linkedLibrary("avdevice"),
                .linkedLibrary("avfilter"),
                .linkedLibrary("avformat"),
                .linkedLibrary("avutil"),
                .linkedLibrary("postproc"),
                .linkedLibrary("swresample"),
                .linkedLibrary("swscale"),
                .linkedLibrary("x264"),
                .unsafeFlags(["-L./Sources/FFReadWriter/ffmpeg-sdk-osx/lib"])
            ]
        )
    ],
    cxxLanguageStandard: .cxx11
)
