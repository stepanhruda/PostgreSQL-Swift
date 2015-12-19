public final class Query: StringLiteralConvertible {
    public let string: String

    public typealias StringLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    public typealias UnicodeScalarLiteralType = String

    public required init(_ string: String) {
        self.string = string
    }

    public convenience init(stringLiteral value: String) {
        self.init(value)
    }

    public convenience init(unicodeScalarLiteral value: String) {
        self.init(value)
    }

    public convenience init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }

    var resultFormat: QueryResultDataFormat {
        return .Binary
    }
}

public enum QueryError: ErrorType {
    case InvalidQuery(errorMessage: String)
}

enum QueryResultDataFormat: Int32 {
    case Text = 0
    case Binary = 1
}
