import libpq

struct ConnectionParameters {
    let host: String
    let port: String
    let options: String
    let tty: String
    let databaseName: String
    let login: String
    let password: String
}

enum ConnectionError: ErrorType {
    case ConnectionFailed
}

class Database {
    static func connect(parameters: ConnectionParameters) throws -> Connection {

        let connectionPointer = PQsetdbLogin(parameters.host,
            parameters.port,
            parameters.options,
            parameters.tty,
            parameters.databaseName,
            parameters.login,
            parameters.password)

        guard PQstatus(connectionPointer) == CONNECTION_OK else { throw ConnectionError.ConnectionFailed }

        return Connection(pointer: connectionPointer)
    }
}

enum QueryError: ErrorType {
    case InvalidQuery
}

public class Connection {
    let pointer: COpaquePointer

    init(pointer: COpaquePointer) {
        self.pointer = pointer
    }

    func execute(query: Query) throws -> QueryResult {
        let resultPointer = PQexec(pointer, query.string)

        let status = PQresultStatus(resultPointer)

        switch status {
        case PGRES_COMMAND_OK, PGRES_TUPLES_OK: break
        default: throw QueryError.InvalidQuery
        }

        return QueryResult(pointer: resultPointer)
    }
}

public final class Query: StringLiteralConvertible {
    let string: String

    public typealias StringLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    public typealias UnicodeScalarLiteralType = String

    public required init(string: String) {
        self.string = string
    }

    public convenience init(stringLiteral value: String) {
        self.init(string: value)
    }

    public convenience init(unicodeScalarLiteral value: String) {
        self.init(string: value)
    }

    public convenience init(extendedGraphemeClusterLiteral value: String) {
        self.init(string: value)
    }
}

struct QueryResult {
    let pointer: COpaquePointer

    init(pointer: COpaquePointer) {
        self.pointer = pointer
    }
}

