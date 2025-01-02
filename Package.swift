// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "pocketdo-ios",
    platforms: [.iOS(.v16)],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.0.0"),
        .package(url: "https://github.com/onevcat/Kingfisher", from: "7.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.8.0"),
    ],
    targets: [
        .executableTarget(
            name: "pocketdo-ios",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "Alamofire", package: "Alamofire"),
            ]
        ),
        .testTarget(name: "pocketdo-iosTests", dependencies: [.target(name: "pocketdo-ios")])
    ]
)
