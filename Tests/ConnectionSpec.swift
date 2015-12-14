import Quick
import Nimble
@testable import Elephant

class ConnectionSpec: QuickSpec {

    override func spec() {

        describe("execute") {
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
            }

            context("when executing a valid query") {
                it("doesn't throw an error") {
                    guard connectionErrorMessage == nil else { fail(connectionErrorMessage!); return }

                    expect {
                        try connection.execute("SELECT 1;")
                        return nil
                        }.toNot(throwError())
                }
            }

            context("when executing an invalid query") {
                it("throws an invalid query error") {
                    guard connectionErrorMessage == nil else { fail(connectionErrorMessage!); return }

                    expect {
                        try connection.execute("OH MY GOD;")
                        return nil
                        }.to(throwError(errorType: QueryError.self))
                }
            }

            it("selects a boolean") {
                guard connectionErrorMessage == nil else { fail(connectionErrorMessage!); return }

                let result = try! connection.execute("SELECT true;")
                expect(result.rows[0].columnValues[0] as? Bool) == true
            }

            it("selects a 32-bit integer") {
                guard connectionErrorMessage == nil else { fail(connectionErrorMessage!); return }

                let result = try! connection.execute("SELECT 42;")
                expect(result.rows[0].columnValues[0] as? Int32) == 42
            }
        }
    }
}
