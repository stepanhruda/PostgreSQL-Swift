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
let queryResult = try connection.execute("SELECT color, texture, taste FROM bananas")
for row in queryResult.rows {
    for value in row.columnValues {
        // Called for color, texture and taste in every row
    }
}
```

### Roadmap

[We are tracking our roadmap with a GitHub issue](https://github.com/stepanhruda/Elephant/issues/5)
