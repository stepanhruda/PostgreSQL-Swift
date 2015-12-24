/// A single row in a query table.
///
/// This class currently depends on the original `QueryResult` still being available.
public struct QueryResultRow {
    public let columnValues: [Any?]
    unowned let queryResult: QueryResult

    public subscript(columnName: String) -> Any? {
        get {
            guard let index = queryResult.columnIndexesForNames[columnName] else { return nil }
            return columnValues[index]
        }
    }
}
