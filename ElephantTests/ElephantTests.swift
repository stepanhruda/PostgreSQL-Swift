import Quick
import Nimble
@testable import Elephant

class ElephantTests: QuickSpec {

    override func spec() {

        let validDatabaseParameters = ConnectionParameters(
            host: "192.168.99.100",
            port: "32768",
            options: "",
            tty: "",
            databaseName: "elephant",
            login: "postgres",
            password: "")

        describe("Connection") {

            context("with valid connection parameters") {
                it("returns a connection") {

                    expect {
                        try Database.connect(validDatabaseParameters)
                        return nil
                        }.toNot(throwError())
                }
            }

            context("with invalid connection parameters") {
                it("throws a connection failed error") {

                    expect {

                        let parameters = ConnectionParameters(
                            host: "",
                            port: "",
                            options: "",
                            tty: "",
                            databaseName: "",
                            login: "",
                            password: "")
                        
                        try Database.connect(parameters)
                        return nil
                        }.to(throwError(errorType: ConnectionError.self))
                }
            }
        }

        describe("Query") {
            let connection = try! Database.connect(validDatabaseParameters)

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
