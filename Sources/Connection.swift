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

    public func execute(query: Query, params: [Parameter] = []) throws -> QueryResult {
        var types = params.map { $0.type.rawValue }
        var values: [UnsafePointer<Int8>] = params.map { param in
            var param = param
            return UnsafePointer<Int8>(param.asBinary)
        }

        var lengths = params.map { Int32($0.length) }
        var formats = params.map { _ in return QueryDataFormat.Binary.rawValue }

        let resultPointer = PQexecParams(connectionPointer,
                                         query.string,
                                         Int32(params.count),
                                         &types,
                                         &values,
                                         &lengths,
                                         &formats,
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

public protocol Parameter {
    var type: ColumnType { get }
    var length: Int { get }
    var asBinary: [UInt8] { get }
}

extension Int: Parameter {
    public var type: ColumnType {
        return .Int32
    }

    public var length: Int {
        return sizeof(Int)
    }

    public var asBinary: [UInt8] {
        return byteArrayFrom(self)
    }
}

extension Int16: Parameter {
    public var type: ColumnType {
        return .Int16
    }

    public var length: Int {
        return sizeof(Int16)
    }

    public var asBinary: [UInt8] {
        return byteArrayFrom(self.byteSwapped)
    }
}

extension Int32: Parameter {
    public var type: ColumnType {
        return .Int32
    }

    public var length: Int {
        return sizeof(Int32)
    }

    public var asBinary: [UInt8] {
        return byteArrayFrom(self)
    }
}

extension Int64: Parameter {
    public var type: ColumnType {
        return .Int64
    }

    public var length: Int {
        return sizeof(Int64)
    }

    public var asBinary: [UInt8] {
        return byteArrayFrom(self)
    }
}

extension Bool: Parameter {
    public var type: ColumnType {
        return .Boolean
    }

    public var length: Int {
        return sizeof(Bool)
    }

    public var asBinary: [UInt8] {
        return byteArrayFrom(self)
    }
}
//
//extension String: Parameter {
//    public var type: ColumnType {
//        return .Text
//    }
//
//    public var length: Int {
//        return self.
//    }
//}

extension Float: Parameter {
    public var type: ColumnType {
        return .SingleFloat
    }

    public var length: Int {
        return sizeof(Float)
    }

    public var asBinary: [UInt8] {
        return byteArrayFrom(self)
    }
}

extension Double: Parameter {
    public var type: ColumnType {
        return .DoubleFloat
    }

    public var length: Int {
        return sizeof(Double)
    }

    public var asBinary: [UInt8] {
        return byteArrayFrom(self)
    }
}

//extension Array: Parameter {
//    public var type: ColumnType {
//        return .Binary
//    }
//
//    public var length: Int {
//        return sizeof(Array)
//    }
//}