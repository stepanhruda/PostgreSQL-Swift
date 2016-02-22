/// Supported types from Postgres's type system.
public enum ColumnType: UInt32 {
    case Boolean = 16
    case Int64 = 20
    case Int16 = 21
    case Int32 = 23
    case Text = 25
    case SingleFloat = 700
    case DoubleFloat = 701
}
