import PackageDescription

let package = Package(
  name: "Elephant",
  dependencies: [
    .Package(url: "https://github.com/stepanhruda/libpq.git", majorVersion: 9)
  ]
)

