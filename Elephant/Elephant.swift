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
    let connectionPointer: COpaquePointer

    init(pointer: COpaquePointer) {
        self.connectionPointer = pointer
    }

    func execute(query: Query) throws -> QueryResult {
        let resultPointer = PQexec(connectionPointer, query.string)

        let status = PQresultStatus(resultPointer)

        switch status {
        case PGRES_COMMAND_OK, PGRES_TUPLES_OK: break
        default: throw QueryError.InvalidQuery
        }

        return QueryResult(resultPointer: resultPointer)
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
    let resultPointer: COpaquePointer

    init(resultPointer: COpaquePointer) {
        self.resultPointer = resultPointer
    }

    lazy var rows: [ResultRow] = {
        return QueryResult.cacheRowsForResult(self)
    }()

    static func cacheRowsForResult(result: QueryResult) -> [ResultRow] {
        let numberOfColumns = PQnfields(result.resultPointer)
        let numberOfRows = PQntuples(result.resultPointer)

        var typesForColumns = [UInt32]()
        typesForColumns.reserveCapacity(Int(numberOfColumns))

        for columnNumber in 0..<numberOfColumns {
            let typeId = PQftype(result.resultPointer, columnNumber)
            typesForColumns[Int(columnNumber)] = typeId
        }

        for rowNumber in 0..<numberOfRows {
            for columnNumber in 0..<numberOfColumns {
                let value = PQgetvalue(result.resultPointer, rowNumber, columnNumber)
            }
        }

        return []
    }
}

struct ResultRow {
    let columnValues: [ColumnValue]
}

enum ColumnValue {
    case Boolean(Bool)
    case Data([UInt8])
// Unsupported until available in Swift Foundation
//    case Date(NSDate)
    case DoubleType(Double)
    case Integer(Int)
    case Text(String)
}

