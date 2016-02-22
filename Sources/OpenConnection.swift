import libpq

/// An open connection to the database usable for executing queries.
///
/// This object is NOT threadsafe, each thread needs to acquire its own open connection from `Database`.
public class OpenConnection {

    /// Executes a query.
    ///
    /// First parameter is referred to as `$1` in the query.
    public func execute(query: String, parameters: [Parameter] = []) throws -> QueryResult {
        let values = UnsafeMutablePointer<UnsafePointer<Int8>>.alloc(parameters.count)

        defer {
            values.destroy()
            values.dealloc(parameters.count)
        }

        var temps = [Array<UInt8>]()
        for (i, value) in parameters.enumerate() {
            temps.append(Array<UInt8>(value.asString.utf8) + [0])
            values[i] = UnsafePointer<Int8>(temps.last!)
        }

        let resultPointer = PQexecParams(connectionPointer,
                                         query,
                                         Int32(parameters.count),
                                         nil,
                                         values,
                                         nil,
                                         nil,
                                         QueryDataFormat.Binary.rawValue)

        let status = PQresultStatus(resultPointer)

        switch status {
        case PGRES_COMMAND_OK, PGRES_TUPLES_OK: break
        default:
            let message = String.fromCString(PQresultErrorMessage(resultPointer)) ?? "Unknown error"
            throw ConnectionError.InvalidQuery(message: message)
        }

        return QueryResult(resultPointer: resultPointer)
    }

    // MARK: Internal and private

    private var connectionPointer: COpaquePointer

    init(parameters: ConnectionParameters = ConnectionParameters()) throws {
        connectionPointer = PQsetdbLogin(parameters.host,
                                         parameters.port,
                                         parameters.options,
                                         "",
                                         parameters.databaseName,
                                         parameters.user,
                                         parameters.password)

        guard PQstatus(connectionPointer) == CONNECTION_OK else {
            let message = String.fromCString(PQerrorMessage(connectionPointer))
            throw ConnectionError.ConnectionFailed(message: message ?? "Unknown error")
        }
    }

    deinit {
        PQfinish(connectionPointer)
    }

    private enum QueryDataFormat: Int32 {
        case Text = 0
        case Binary = 1
    }
}

public enum ConnectionError: ErrorType {
    case ConnectionFailed(message: String)
    case InvalidQuery(message: String)
}
