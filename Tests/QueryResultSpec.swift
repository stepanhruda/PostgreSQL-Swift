import Quick
import Nimble
@testable import PostgreSQL

class QueryResultSpec: QuickSpec {

    override func spec() {

        describe("rows") {
            var connection: Connection!
            var connectionErrorMessage: String?

            beforeEach {
                connectionErrorMessage = nil

                do {
                    connection = try Database.connect()
                } catch let error as ConnectionError {
                    switch error {
                    case .ConnectionFailed(message: let message):
                        connectionErrorMessage = message
                    }
                } catch { connectionErrorMessage = "Unknown error" }

                let createDatabase =
                "CREATE TABLE spec (" +
                    "int16_column int2," +
                    "int32_column int4," +
                    "int64_column int8," +
                    "text_column text," +
                    "single_float_column float4," +
                    "double_float_column float8," +
                    "boolean_column boolean," +
                    "raw_byte_column bytea" +
                ");"

                _ = try? connection.execute(Query(createDatabase))
            }

            afterEach {
                _ = try? connection.execute("DROP TABLE spec;")
            }
            context("without query parameters") {


                it("returns a selected a boolean") {
                    guard connectionErrorMessage == nil else { fail(connectionErrorMessage!); return }

                    _ = try! connection.execute("INSERT INTO spec (boolean_column) VALUES (true);")

                    let result = try! connection.execute("SELECT boolean_column FROM spec;")
                    expect(result.rows[0]["boolean_column"] as? Bool) == true
                }

                it("returns a selected 16-bit integer") {
                    guard connectionErrorMessage == nil else { fail(connectionErrorMessage!); return }

                    _ = try! connection.execute("INSERT INTO spec (int16_column) VALUES (42);")

                    let result = try! connection.execute("SELECT int16_column FROM spec;")
                    expect(result.rows[0]["int16_column"] as? Int16) == 42
                }

                it("returns a selected 32-bit integer") {
                    guard connectionErrorMessage == nil else { fail(connectionErrorMessage!); return }

                    _ = try! connection.execute("INSERT INTO spec (int32_column) VALUES (42);")

                    let result = try! connection.execute("SELECT int32_column FROM spec;")
                    expect(result.rows[0]["int32_column"] as? Int32) == 42
                }

                it("returns a selected 64-bit integer") {
                    guard connectionErrorMessage == nil else { fail(connectionErrorMessage!); return }

                    _ = try! connection.execute("INSERT INTO spec (int64_column) VALUES (42);")

                    let result = try! connection.execute("SELECT int64_column FROM spec;")
                    expect(result.rows[0]["int64_column"] as? Int64) == 42
                }

                it("returns a selected a string") {
                    guard connectionErrorMessage == nil else { fail(connectionErrorMessage!); return }

                    _ = try! connection.execute("INSERT INTO spec (text_column) VALUES ('indigo');")

                    let result = try! connection.execute("SELECT text_column FROM spec;")
                    expect(result.rows[0]["text_column"] as? String) == "indigo"
                }

                it("returns selected raw bytes") {
                    guard connectionErrorMessage == nil else { fail(connectionErrorMessage!); return }

                    _ = try! connection.execute("INSERT INTO spec (raw_byte_column) VALUES (E'\\\\xAFFFEF01FF01');")

                    let result = try! connection.execute("SELECT raw_byte_column FROM spec;")
                    expect(result.rows[0]["raw_byte_column"] as? [UInt8]) == [175, 255, 239, 1, 255, 1]
                }

                it("returns a selected a float") {
                    guard connectionErrorMessage == nil else { fail(connectionErrorMessage!); return }

                    _ = try! connection.execute("INSERT INTO spec (single_float_column) VALUES (54564.7654);")

                    let result = try! connection.execute("SELECT single_float_column FROM spec;")
                    expect(result.rows[0]["single_float_column"] as? Float) == 54564.7654
                }

                it("returns a selected a double") {
                    guard connectionErrorMessage == nil else { fail(connectionErrorMessage!); return }
                    
                    _ = try! connection.execute("INSERT INTO spec (double_float_column) VALUES (4.99);")
                    
                    let result = try! connection.execute("SELECT double_float_column FROM spec;")
                    expect(result.rows[0]["double_float_column"] as? Double) == 4.99
                }
            }
            context("with query parameters") {

                it("returns a selected a boolean") {
                    guard connectionErrorMessage == nil else { fail(connectionErrorMessage!); return }

                    _ = try! connection.execute("INSERT INTO spec (boolean_column) VALUES (true);")

                    let result = try! connection.execute("SELECT boolean_column FROM spec WHERE boolean_column = $1;", params: [true])
                    expect(result.rows[0]["boolean_column"] as? Bool) == true
                }

                it("returns a selected 16-bit integer") {
                    guard connectionErrorMessage == nil else { fail(connectionErrorMessage!); return }

                    _ = try! connection.execute("INSERT INTO spec (int16_column) VALUES (42);")

                    let result = try! connection.execute("SELECT int16_column FROM spec WHERE int16_column = $1;", params: [Int16(42)])
                    expect(result.rows[0]["int16_column"] as? Int16) == 42
                }

                it("returns a selected 32-bit integer") {
                    guard connectionErrorMessage == nil else { fail(connectionErrorMessage!); return }

                    _ = try! connection.execute("INSERT INTO spec (int32_column) VALUES (42);")

                    let result = try! connection.execute("SELECT int32_column FROM spec where int32_column = $1;", params: [Int32(42)])
                    expect(result.rows[0]["int32_column"] as? Int32) == 42
                }

                it("returns a selected 64-bit integer") {
                    guard connectionErrorMessage == nil else { fail(connectionErrorMessage!); return }

                    _ = try! connection.execute("INSERT INTO spec (int64_column) VALUES (42);")

                    let result = try! connection.execute("SELECT int64_column FROM spec WHERE int64_column = $1;", params: [42])
                    expect(result.rows[0]["int64_column"] as? Int64) == 42
                }

//                it("returns a selected a string") {
//                    guard connectionErrorMessage == nil else { fail(connectionErrorMessage!); return }
//
//                    _ = try! connection.execute("INSERT INTO spec (text_column) VALUES ('indigo');")
//
//                    let result = try! connection.execute("SELECT text_column FROM spec WHERE text_column = $1;", params: ["indigo"])
//                    expect(result.rows[0]["text_column"] as? String) == "indigo"
//                }
//
//                it("returns selected raw bytes") {
//                    guard connectionErrorMessage == nil else { fail(connectionErrorMessage!); return }
//
//                    _ = try! connection.execute("INSERT INTO spec (raw_byte_column) VALUES (E'\\\\xAFFFEF01FF01');")
//
//                    let result = try! connection.execute("SELECT raw_byte_column FROM spec WHERE raw_byte_column = $1;", params: [ [175, 255, 239, 1, 255, 1] ])
//                    expect(result.rows[0]["raw_byte_column"] as? [UInt8]) == [175, 255, 239, 1, 255, 1]
//                }

                it("returns a selected a float") {
                    guard connectionErrorMessage == nil else { fail(connectionErrorMessage!); return }

                    _ = try! connection.execute("INSERT INTO spec (single_float_column) VALUES (54564.7654);")

                    let result = try! connection.execute("SELECT single_float_column FROM spec WHERE single_float_column = $1;", params: [54564.7654])
                    expect(result.rows[0]["single_float_column"] as? Float) == 54564.7654
                }

                it("returns a selected a double") {
                    guard connectionErrorMessage == nil else { fail(connectionErrorMessage!); return }
                    
                    _ = try! connection.execute("INSERT INTO spec (double_float_column) VALUES (4.99);")
                    
                    let result = try! connection.execute("SELECT double_float_column FROM spec WHERE double_float_column = $1;", params: [4.99])
                    expect(result.rows[0]["double_float_column"] as? Double) == 4.99
                }
            }
        }
    }
}
