#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

public struct ConnectionParameters {
    public let host: String
    public let port: String
    public let options: String
    public let databaseName: String
    public let user: String
    public let password: String

    public init(host: String = String.fromCString(getenv("PGHOST")) ?? "",
        port: String = String.fromCString(getenv("PGPORT")) ?? "",
        options: String = String.fromCString(getenv("PGOPTIONS")) ?? "",
        databaseName: String = String.fromCString(getenv("PGDATABASE")) ?? "",
        user: String = String.fromCString(getenv("PGUSER")) ?? "",
        password: String = String.fromCString(getenv("PGPASSWORD")) ?? "") {
            self.host = host
            self.port = port
            self.options = options
            self.databaseName = databaseName
            self.user = user
            self.password = password
    }
}
