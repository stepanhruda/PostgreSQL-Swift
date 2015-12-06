#if os(Linux)
 import Glibc
#else
 import Darwin
#endif

import libpq

public struct ConnectionParameters {
    let host: String
    let port: String
    let options: String
    let tty: String
    let databaseName: String
    let login: String
    let password: String

    public init(host: String = String.fromCString(getenv("POSTGRES_HOST")) ?? "",
        port: String = String.fromCString(getenv("POSTGRES_PORT")) ?? "",
        options: String = String.fromCString(getenv("POSTGRES_OPTIONS")) ?? "",
        tty: String = String.fromCString(getenv("POSTGRES_TTY")) ?? "",
        databaseName: String = String.fromCString(getenv("POSTGRES_DATABASE_NAME")) ?? "",
        login: String = String.fromCString(getenv("POSTGRES_LOGIN")) ?? "",
        password: String = String.fromCString(getenv("POSTGRES_PASSWORD")) ?? "") {
            self.host = host
            self.port = port
            self.options = options
            self.tty = tty
            self.databaseName = databaseName
            self.login = login
            self.password = password
    }
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

public final class QueryResult {
    let resultPointer: COpaquePointer

    init(resultPointer: COpaquePointer) {
        self.resultPointer = resultPointer
    }

    lazy var numberOfRows: Int32 = {
        return PQntuples(self.resultPointer)
    }()

    lazy var numberOfColumns: Int32 = {
        return PQnfields(self.resultPointer)
    }()

    lazy var rows: [ResultRow] = {
        var typesForColumns = [UInt32]()
        typesForColumns.reserveCapacity(Int(self.numberOfColumns))

        for columnNumber in 0..<self.numberOfColumns {
            let typeId = PQftype(self.resultPointer, columnNumber)
            typesForColumns[Int(columnNumber)] = typeId
        }

        for rowNumber in 0..<self.numberOfRows {
            for columnNumber in 0..<self.numberOfColumns {
                let value = PQgetvalue(self.resultPointer, rowNumber, columnNumber)
            }
        }

        return []
    }()
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

