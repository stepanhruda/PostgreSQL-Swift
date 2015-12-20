Connect to your PostgreSQL database. Run queries. All natively in Swift.

### Usage

#### Connection

```swift
let parameters = ConnectionParameters(
  host: "123.123.123.123",
  port: "9000",
  databaseName: "banana_pantry",
  login: "mehungry",
  password: "reallyhungrygotnopatience"
)
let connection = try Database.connect(parameters: parameters)
```

#### Environment variables

Your database configuration should not be in your application's source. Connecting to the database becomes as easy as:

```swift
let connection = try Database.connect()
```

Configuration is automatically loaded from default PostgreSQL environment variables.

```shell
export PGHOST 123.123.123.123
export PGPORT 9000
export PGDATABASE banana_pantry
export PGUSER mehungry
export PGPASSWORD reallyhungrygotnopatience
```

#### Queries and results

```swift
let result = try connection.execute("SELECT color, is_tasty, length FROM bananas")
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

