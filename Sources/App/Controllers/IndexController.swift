import Vapor
import Leaf

struct IndexController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: index)
        router.get("users", User.parameter, use: samples)
        router.get("users", use: users)
        router.get("users", "create", use: userCreate)
        router.post(User.self, at: "users", use: users)
        router.post("users", User.parameter, "samples", use: sampleCreate)
        router.post("samples", Sample.parameter, String.parameter, use: sampleEdit)
        router.post("samples", "delete", Sample.parameter, use: sampleDelete)
    }
    
    func sampleDelete(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(Sample.self)
            .flatMap(to: Response.self) { sample in
                let userID = sample.userID
                return sample.delete(on: req)
                    .transform(to: req.redirect(to: "/users/\(userID)"))
        }
    }
    
    func sampleEdit(_ req: Request) throws -> Future<Response> {
        let sample = try req.parameters.next(Sample.self)
        let value = try req.parameters.next(String.self)
        return sample.flatMap { updatedSample in
            if value.lowercased() == "true" {
                updatedSample.isProcessed = true
            } else if value.lowercased() == "false" {
                updatedSample.isProcessed = false
            }
            
            return updatedSample.save(on: req)
                .map(to: Response.self) { savedSample in
                    guard savedSample.id != nil else {
                        throw Abort(.internalServerError)
                    }
                    return req.redirect(to: "/users/\(savedSample.user.parentID)")
            }
        }
    }
    
    func sampleCreate(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(User.self)
            .flatMap(to: Response.self) { user in
                guard let userID = user.id else {
                    throw Abort(.internalServerError)
                }
                let sample = Sample(userID: userID, isProcessed: false)
                return sample.save(on: req)
                    .map(to: Response.self) { sample in
                        guard sample.id != nil else {
                            throw Abort(.internalServerError)
                        }
                        return req.redirect(to: "/users/\(userID)")
                }
        }
    }
    
    func users(_ req: Request, user: User) throws -> Future<Response> {
        return user.save(on: req)
            .map(to: Response.self) { user in
                guard let userID = user.id else {
                    throw Abort(.internalServerError)
                }
                return req.redirect(to: "/users/\(userID)")
        }
    }
    
    func userCreate(_ req: Request) throws -> Future<View> {
        let titleContext = TitleContext(title: "Create Users")
        return try req.view().render("userCreate", titleContext)
    }
    
    func index(_ req: Request) throws -> Future<View> {
        let titleContext = TitleContext(title: "Bio Lab")
        return try req.view().render("index", titleContext)
    }
    
    func samples(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(User.self)
            .flatMap(to: View.self) { user in
                return try user.samples.query(on: req).all()
                    .flatMap(to: View.self) { samples in
                        let sampleContext = SampleContext(title: "Samples", samples: samples, user: user)
                        return try req.view().render("sample", sampleContext)
                }
        }
    }
    
    func users(_ req: Request) throws -> Future<View> {
        return User.query(on: req)
            .all()
            .flatMap(to: View.self) { userModels in
                let users = userModels.isEmpty ? nil: userModels
                let indexContext = UserContext(title: "Users", users: users)
                return try req.view().render("user", indexContext)
        }
    }
}

struct TitleContext: Encodable {
    let title: String
}

struct UserContext: Encodable {
    let title: String
    let users: [User]?
}

struct SampleContext: Encodable {
    let title: String
    let samples: [Sample]
    let user: User
}
