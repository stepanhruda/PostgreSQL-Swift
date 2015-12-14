import libpq
#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

/// Results are readonly operations and therefore threadsafe.
public final class QueryResult {
    let resultPointer: COpaquePointer

    init(resultPointer: COpaquePointer) {
        self.resultPointer = resultPointer
    }

    deinit {
        PQclear(resultPointer)
    }

    public lazy var columnIndexesForNames: [String: Int] = {
        var columnIndexesForNames = [String: Int]()

        for columnNumber in 0..<self.numberOfColumns {
            let name = String.fromCString(PQfname(self.resultPointer, columnNumber))!
            columnIndexesForNames[name] = Int(columnNumber)
        }

        return columnIndexesForNames
    }()

    public lazy var numberOfRows: Int32 = {
        return PQntuples(self.resultPointer)
    }()

    public lazy var numberOfColumns: Int32 = {
        return PQnfields(self.resultPointer)
    }()

    lazy var typesForColumnIndexes: [ColumnType?] = {
        var typesForColumns = [ColumnType?]()
        typesForColumns.reserveCapacity(Int(self.numberOfColumns))

        for columnNumber in 0..<self.numberOfColumns {
            let typeId = PQftype(self.resultPointer, columnNumber)
            typesForColumns.append(ColumnType(rawValue: typeId))
        }

        return typesForColumns
    }()

    public lazy var rows: [ResultRow] = {
        var rows = [ResultRow]()
        rows.reserveCapacity(Int(self.numberOfRows))

        for rowIndex in 0..<self.numberOfRows {
            rows.append(self.readResultRowAtIndex(rowIndex))
        }

        return rows
    }()

    private func readResultRowAtIndex(rowIndex: Int32) -> ResultRow {
        var values = [Any?]()
        values.reserveCapacity(Int(self.numberOfColumns))

        for columnIndex in 0..<self.numberOfColumns {
            values.append(readColumnValueAtIndex(columnIndex, rowIndex: rowIndex))
        }

        return ResultRow(columnValues: values, queryResult: self)
    }

    private func readColumnValueAtIndex(columnIndex: Int32, rowIndex: Int32) -> Any? {
        guard PQgetisnull(self.resultPointer, rowIndex, columnIndex) == 0 else { return nil }

        let firstBytePointer = PQgetvalue(self.resultPointer, rowIndex, columnIndex)

        guard let type = self.typesForColumnIndexes[Int(columnIndex)] else {
            let length = Int(PQgetlength(self.resultPointer, rowIndex, columnIndex))
            return readBytesStartingAtPointer(firstBytePointer, length: length)
        }

        switch type {
        case .Boolean: return UnsafeMutablePointer<Bool>(firstBytePointer).memory
        case .Int16: return swapInt16Bytes(UnsafeMutablePointer<Int16>(firstBytePointer).memory)
        case .Int32: return swapInt32Bytes(UnsafeMutablePointer<Int32>(firstBytePointer).memory)
        case .Int64: return swapInt64Bytes(UnsafeMutablePointer<Int64>(firstBytePointer).memory)
//        case .SingleFloat: return parseDouble()
//            case .DoubleFloat: return parseDouble(bytes)
        case .Text: return String.fromCString(firstBytePointer)!
            default: return nil
        }
    }

    private func readBytesStartingAtPointer(pointer: UnsafeMutablePointer<Int8>, length: Int) -> [Int8] {
        var pointer = pointer
        var bytes: [Int8] = []
        bytes.reserveCapacity(length)

        for _ in 0..<length {
            bytes.append(pointer.memory)
            pointer = pointer.advancedBy(1)
        }

        return bytes
    }
}

public struct ResultRow {
    public let columnValues: [Any?]
    unowned let queryResult: QueryResult

    subscript(columnName: String) -> Any? {
        get {
            guard let index = queryResult.columnIndexesForNames[columnName] else { return nil }
            return columnValues[index]
        }
    }
}

enum ColumnType: UInt32 {
    case Boolean = 16
    case Int64 = 20
    case Int16 = 21
    case Int32 = 23
    case Text = 25
    case SingleFloat = 700
    case DoubleFloat = 701
}

private func swapInt16Bytes(input: Int16) -> Int16 {
#if os(Linux)
    return Int16(htons(__uint16_t(input)))
#else
    return Int16(_OSSwapInt16(__uint16_t(input)))
#endif
}

private func swapInt32Bytes(input: Int32) -> Int32 {
#if os(Linux)
    return Int32(htonl(__uint32_t(input)))
#else
    return Int32(_OSSwapInt32(__uint32_t(input)))
#endif
}

private func swapInt64Bytes(input: Int64) -> Int64 {
#if os(Linux)
    return Int64(htobe64(__uint64_t(input)))
#else
    return Int64(_OSSwapInt64(__uint64_t(input)))
#endif
}


