import Vapor
import Fluent

struct UserController: RouteCollection {
    func boot(router: Router) throws {
        let users = router.grouped("v1", "users")
        
        users.get(use: getUsers)
        
        
        
        router.get("v1", "users", "find", Int.parameter) { req -> Future<User> in
            let userID = try req.parameters.next(Int.self)
            return User.find(userID, on: req)
                .unwrap(or: Abort(HTTPStatus.notFound))
        }
        
        router.get("v1", "users", "sorted") { req -> Future<[User]> in
            return User.query(on: req)
                .sort(\.firstName, .ascending).all()
        }
        
        router.post("v1", "users") { req -> Future<User> in
            return try req.content.decode(User.self)
                .flatMap(to: User.self) { user in
                    return user.save(on: req)
            }
        }
        
        router.put("v1", "users", User.parameter) { req -> Future<User> in
            return try flatMap(to: User.self,
                               req.parameters.next(User.self),
                               req.content.decode(User.self)) { user, updatedUser in
                                user.firstName = updatedUser.firstName
                                user.lastName = updatedUser.lastName
                                user.age = updatedUser.age
                                
                                return user.save(on: req)
            }
        }
        
        router.delete("v1", "users", User.parameter) { req -> Future<HTTPStatus> in
            return try req.parameters.next(User.self)
                .delete(on: req)
                .transform(to: HTTPStatus.noContent)
        }
        
        
    }
    
    func getUsers(_ req: Request) throws -> Future<[User]> {
        if let queryString = req.query[String.self, at: "firstName"] {
            return User.query(on: req).filter(\.firstName == queryString).all()
        }
        return User.query(on: req).all()
    }
}
