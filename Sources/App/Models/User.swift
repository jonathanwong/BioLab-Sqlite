import Vapor
import FluentSQLite

final class User: Codable {
    
    var id: Int?
    var firstName: String
    var lastName: String
    var age: Int
    
    init(firstName: String, lastName: String, age: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
    }
}

extension User: SQLiteModel {}

extension User: Migration {}

extension User: Content {}

extension User: Parameter {}

extension User {
    var samples: Children<User, Sample> {
        return children(\.userID)
    }
}
