#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

public struct ConnectionParameters {
    public let host: String
    public let port: String
    public let options: String
    public let tty: String
    public let databaseName: String
    public let login: String
    public let password: String

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
