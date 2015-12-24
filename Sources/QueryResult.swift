import libpq

/// Results are lazily evaluated, i.e. you cannot close the connection used the execute the query,
/// and start asking questions you haven't previously asked.
public final class QueryResult {
    let resultPointer: COpaquePointer

    init(resultPointer: COpaquePointer) {
        self.resultPointer = resultPointer
    }

    deinit {
        PQclear(resultPointer)
    }

    /// All of the rows in the query table.
    public lazy var rows: [QueryResultRow] = {
        var rows = [QueryResultRow]()
        rows.reserveCapacity(Int(self.numberOfRows))

        for rowIndex in 0..<self.numberOfRows {
            rows.append(self.readResultRowAtIndex(rowIndex))
        }

        return rows
    }()

    /// Number of rows in the resulting table.
    public lazy var numberOfRows: Int32 = {
        return PQntuples(self.resultPointer)
    }()

    /// Number of columns in the resulting table.
    public lazy var numberOfColumns: Int32 = {
        return PQnfields(self.resultPointer)
    }()

    /// Types for columns in the resulting table, indexed by the column number.
    ///
    /// If the column type isn't currently supported, `nil` is returned.
    lazy var typesForColumnIndexes: [ColumnType?] = {
        var typesForColumns = [ColumnType?]()
        typesForColumns.reserveCapacity(Int(self.numberOfColumns))

        for columnNumber in 0..<self.numberOfColumns {
            let typeId = PQftype(self.resultPointer, columnNumber)
            typesForColumns.append(ColumnType(rawValue: typeId))
        }

        return typesForColumns
    }()

    /// Look up a column index based on a column name.
    public lazy var columnIndexesForNames: [String: Int] = {
        var columnIndexesForNames = [String: Int]()

        for columnNumber in 0..<self.numberOfColumns {
            let name = String.fromCString(PQfname(self.resultPointer, columnNumber))!
            columnIndexesForNames[name] = Int(columnNumber)
        }

        return columnIndexesForNames
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
