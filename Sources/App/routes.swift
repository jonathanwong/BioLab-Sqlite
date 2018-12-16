import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let userController = UserController()
    try router.register(collection: userController)
    
    let sampleController = SampleController()
    try router.register(collection: sampleController)
    
    let indexController = IndexController()
    try router.register(collection: indexController)
}
