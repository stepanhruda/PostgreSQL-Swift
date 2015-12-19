import libpq

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

    public lazy var rows: [QueryResultRow] = {
        var rows = [QueryResultRow]()
        rows.reserveCapacity(Int(self.numberOfRows))

        for rowIndex in 0..<self.numberOfRows {
            rows.append(self.readResultRowAtIndex(rowIndex))
        }

        return rows
    }()

    private func readResultRowAtIndex(rowIndex: Int32) -> QueryResultRow {
        var values = [Any?]()
        values.reserveCapacity(Int(self.numberOfColumns))

        for columnIndex in 0..<self.numberOfColumns {
            values.append(readColumnValueAtIndex(columnIndex, rowIndex: rowIndex))
        }

        return QueryResultRow(columnValues: values, queryResult: self)
    }

    private func readColumnValueAtIndex(columnIndex: Int32, rowIndex: Int32) -> Any? {
        guard PQgetisnull(self.resultPointer, rowIndex, columnIndex) == 0 else { return nil }

        let startingPointer = PQgetvalue(self.resultPointer, rowIndex, columnIndex)

        guard let type = self.typesForColumnIndexes[Int(columnIndex)] else {
            let length = Int(PQgetlength(self.resultPointer, rowIndex, columnIndex))
            // Unsupported column types are returned as [UInt8]
            return byteArrayForPointer(UnsafePointer<UInt8>(startingPointer), length: length)
        }

        switch type {
        case .Boolean: return UnsafePointer<Bool>(startingPointer).memory
        case .Int16: return Int16(bigEndian: UnsafePointer<Int16>(startingPointer).memory)
        case .Int32: return Int32(bigEndian: UnsafePointer<Int32>(startingPointer).memory)
        case .Int64: return Int64(bigEndian: UnsafePointer<Int64>(startingPointer).memory)
        case .SingleFloat: return floatFromInt32(Int32(bigEndian: UnsafePointer<Int32>(startingPointer).memory))
        case .DoubleFloat: return doubleFromInt64(Int64(bigEndian: UnsafePointer<Int64>(startingPointer).memory))
        case .Text: return String.fromCString(startingPointer)!
        }
    }

    private func byteArrayForPointer(start: UnsafePointer<UInt8>, length: Int) -> [UInt8] {
        return Array(UnsafeBufferPointer(start: start, count: length))
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
