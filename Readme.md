Connect to your PostgreSQL database. Run queries. All natively in Swift.

### Installation

Install via [swift-package-manager](https://github.com/apple/swift-package-manager) by adding a depdendency to your _Package.swift_.

```swift
.Package(url: "https://github.com/stepanhruda/PostgreSQL-Swift.git", majorVersion: 0)
```

### Usage

#### Connection

Your database configuration should not be in your application's source. Configuration is automatically loaded from default PostgreSQL environment variables.

```shell
export PGHOST 123.123.123.123
export PGPORT 9000
export PGDATABASE banana_pantry
export PGUSER mehungry
export PGPASSWORD reallyhungrygotnopatience
```

In your application, create a single global database object. It's thread-safe and manages a pool of connections to save resources.

```swift
let database = Database()
```

Now anytime you want to use the database:

```swift
let connection = database.open()

defer {
  database.close(connection)
}

// Use connection to execute queries
```

#### Queries and results

```swift
let result = try connection.execute("SELECT color, is_tasty, length FROM bananas WHERE source = $1;", [palmTree])
for row in result.rows {
  let color = row["color"] as! String
  let isTasty = row["is_tasty"] as! Bool
  let length = row["length"] as! Int
  let banana = Banana(color: color, isTasty: isTasty, length: length)
}
```

### Development on OS X

1. Install dependencies
  * Xcode 7+ (Swift 2.x)
  * `brew cask install dockertoolbox`
1. `make development.setup`
  * Starts a PostgreSQL container that tests can be run against. Before running make sure your _docker-machine_ environment variables are available (usually you run `eval $(docker-machine env default)`)
  * `development.setup` also adds handy opinionated environment variables to your Xcode scheme that connect to the container. If you are using a custom setup rather than what docker-machine gives you out of the box, you might need to tweak them. Also, please don't commit any changes to the `.xcscheme` file.
1. `make test` to run tests or run them through Xcode

