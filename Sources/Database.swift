import libpq
import Venice

/// Used for connecting to the database.
///
/// You usually only need a single instance of this class.
/// Opening and closing connections is guaranteed to be thread-safe.
public class Database {

    /// Opens a connection.
    ///
    /// If no connection is currently available, this method will block until one can be returned.
    public func open() -> OpenConnection {
        return connectionChannel.receive()!
    }

    /// Closes the connection.
    ///
    /// Call close() after you are done executing all queries to free up the connection for further use.
    public func close(connection: OpenConnection) {
        connectionChannel.send(connection)
    }

    public let connectionParameters: ConnectionParameters

    public init(connectionParameters: ConnectionParameters = ConnectionParameters(), maxConnections: Int = 100) throws {
        self.connectionChannel = Channel<OpenConnection>(bufferSize: maxConnections)
        self.connectionParameters = connectionParameters

        for _ in 0..<maxConnections {
            connectionChannel.send(try newConnection())
        }
    }

    // MARK: Internal and private

    private let connectionChannel: Channel<OpenConnection>

    private func newConnection() throws -> OpenConnection {
        return try OpenConnection(parameters: connectionParameters)
    }
}
