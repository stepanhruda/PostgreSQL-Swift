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

    public func execute(query: Query) throws -> QueryResult {
        let resultPointer = PQexec(connectionPointer, query.string)

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
