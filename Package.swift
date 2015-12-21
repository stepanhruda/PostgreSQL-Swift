import PackageDescription

let package = Package(
  name: "PostgreSQL",
  dependencies: [
#if os(Linux)
    .Package(url: "https://github.com/stepanhruda/libpq.git", majorVersion: 9)
#else
    .Package(url: "https://github.com/stepanhruda/libpq-darwin.git", majorVersion: 9)
#endif
  ]
)

