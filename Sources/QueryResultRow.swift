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
