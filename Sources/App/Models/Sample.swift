import Vapor
import FluentSQLite
import Foundation

final class Sample: Codable {
    
    var id: UUID?
    var isProcessed: Bool
    var userID: User.ID
    
    init(userID: User.ID, isProcessed: Bool) {
        self.userID = userID
        self.isProcessed = isProcessed
    }
}

extension Sample: SQLiteUUIDModel {}

extension Sample: Migration {}

extension Sample: Content {}

extension Sample: Parameter {}

extension Sample {
    var user: Parent<Sample, User> {
        return parent(\.userID)
    }
}
