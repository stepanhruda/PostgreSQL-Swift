import libpq

public enum ConnectionError: ErrorType {
    case ConnectionFailed
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

        guard PQstatus(connectionPointer) == CONNECTION_OK else { throw ConnectionError.ConnectionFailed }

        return Connection(pointer: connectionPointer)
    }
}
