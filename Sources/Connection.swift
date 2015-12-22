import libpq

/// A database connection is NOT thread safe.
public class Connection {
    let connectionPointer: COpaquePointer

    init(pointer: COpaquePointer) {
        self.connectionPointer = pointer
    }

    deinit {
        PQfinish(connectionPointer)
    }

    public func execute(query: Query, parameters: [Parameter] = []) throws -> QueryResult {
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
                                         query.string,
                                         Int32(parameters.count),
                                         nil,
                                         values,
                                         nil,
                                         nil,
                                         query.resultFormat.rawValue)

        let status = PQresultStatus(resultPointer)

        switch status {
        case PGRES_COMMAND_OK, PGRES_TUPLES_OK: break
        default:
            let message = String.fromCString(PQresultErrorMessage(resultPointer)) ?? ""
            throw QueryError.InvalidQuery(errorMessage: message)
        }

        return QueryResult(resultPointer: resultPointer)
    }
}

// TODO: Implement on Connection
public enum ConnectionStatus {
    case Connected
    case Disconnected
}
