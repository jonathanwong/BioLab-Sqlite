import Vapor
import Fluent

struct SampleController: RouteCollection {
    func boot(router: Router) throws {
        
        router.post("v1", "samples") { req -> Future<Sample> in
            return try req.content.decode(Sample.self)
                .flatMap(to: Sample.self) { sample in
                    return sample.save(on: req)
            }
        }
        
        // v1/samples/:sampleID/user
        router.get("v1", "samples", Sample.parameter, "user") { req -> Future<User> in
            return try req.parameters.next(Sample.self)
                .flatMap(to: User.self) { sample in
                    sample.user.get(on: req)
            }
        }
        
        // v1/users/:userID/samples
        router.get("v1", "users", User.parameter, "samples") { req -> Future<[Sample]> in
            return try req.parameters.next(User.self)
                .flatMap(to: [Sample].self) { user in
                    try user.samples.query(on: req).all()
            }
        }
    }
    
    
}
