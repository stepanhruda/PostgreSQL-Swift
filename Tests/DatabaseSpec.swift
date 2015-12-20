import Quick
import Nimble
@testable import PostgreSQL

class DatabaseSpec: QuickSpec {

    override func spec() {

        describe("connect") {

            context("with valid connection parameters") {
                it("returns a connection") {

                    expect {
                        try Database.connect()
                        return nil
                        }.toNot(throwError())
                }
            }

            context("with invalid connection parameters") {
                it("throws a connection failed error") {

                    expect {

                        let parameters = ConnectionParameters(host: "sillyhost", port: "666", databaseName: "forgetit", user: "nouser",  password: "forgetit")

                        try Database.connect(parameters: parameters)
                        return nil
                        }.to(throwError(errorType: ConnectionError.self))
                }
            }
        }
    }
}
