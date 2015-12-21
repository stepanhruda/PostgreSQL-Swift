import PackageDescription

#if os(Linux)
let package = Package(
  name: "PostgreSQL",
  dependencies: [
    .Package(url: "https://github.com/stepanhruda/libpq.git", majorVersion: 9)
  ]
)
#else
let package = Package(
  name: "PostgreSQL",
  dependencies: [
    .Package(url: "https://github.com/stepanhruda/libpq-darwin.git", majorVersion: 9)
  ]
)
#endif
