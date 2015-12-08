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

    public lazy var numberOfRows: Int32 = {
        return PQntuples(self.resultPointer)
    }()

    public lazy var numberOfColumns: Int32 = {
        return PQnfields(self.resultPointer)
    }()

    lazy var typesForColumns: [ColumnType?] = {
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

        for rowNumber in 0..<self.numberOfRows {
            var values = [ColumnValue]()
            values.reserveCapacity(Int(self.numberOfColumns))

            for columnNumber in 0..<self.numberOfColumns {
                let rawValue = PQgetvalue(self.resultPointer, rowNumber, columnNumber)

                var value: ColumnValue
                if let type = self.typesForColumns[Int(columnNumber)] {
                    switch type {
                    case .Boolean: value = .Boolean(nil)
                    case .SingleFloat, .DoubleFloat: value = .DoubleType(nil)
                    case .Int64, .Int16, .Int32: value = .Integer(nil)
                    case .Text: value = .Text(nil)
                    }
                } else {
                    value = .Data(nil)
                }

                values.append(value)
            }

            rows.append(ResultRow(columnValues: values))
        }

        return rows
    }()
}

public struct ResultRow {
    public let columnValues: [ColumnValue]
}

public enum ColumnValue {
    case Boolean(Bool?)
    case Data([UInt8]?)
    case DoubleType(Double?)
    case Integer(Int?)
    case Text(String?)
}

enum ColumnType: UInt32 {
    case Boolean = 16
    case SingleFloat = 700
    case DoubleFloat = 701
    case Int64 = 20
    case Int16 = 21
    case Int32 = 23
    case Text = 25
}

