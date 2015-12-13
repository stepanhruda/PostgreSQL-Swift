import libpq

public enum ConnectionError: ErrorType {
    case ConnectionFailed(message: String)
}

public class Database {
    public static func connect(parameters parameters: ConnectionParameters = ConnectionParameters()) throws -> Connection {

        let connectionPointer = PQsetdbLogin(parameters.host,
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

        return Connection(pointer: connectionPointer)
    }
}
