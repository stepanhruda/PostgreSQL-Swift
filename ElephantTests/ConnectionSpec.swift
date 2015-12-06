import Quick
import Nimble
@testable import Elephant

class ConnectionSpec: QuickSpec {

    override func spec() {

        describe("execute") {
            let connection = try! Database.connect()

            context("when executing a valid query") {
                it("doesn't throw an error") {
                    expect {
                        try connection.execute("SELECT 1;")
                        return nil
                        }.toNot(throwError())
                }
            }

            context("when executing an invalid query") {
                it("throws an invalid query error") {
                    expect {
                        try connection.execute("OH MY GOD;")
                        return nil
                        }.to(throwError(errorType: QueryError.self))
                }
            }
        }
    }
}
