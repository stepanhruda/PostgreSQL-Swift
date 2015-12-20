import PackageDescription

let package = Package(
  name: "PostgreSQL",
  dependencies: [
    .Package(url: "https://github.com/stepanhruda/libpq.git", majorVersion: 9)
  ]
)

