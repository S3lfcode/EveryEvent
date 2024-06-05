import Foundation
import UIKit

//MARK: Screens
extension Assembly {
    
    func appCoordinator() -> AppCoordinator {
        .init(assembly: self)
    }
    
    func regCoordinator() -> RegCoordinator {
        .init(assembly: self)
    }
    
    func authCoordinator() -> AuthCoordinator {
        .init(assembly: self)
    }
    
    func catalogCoordinator() -> CatalogCoordinator {
        .init(assembly: self)
    }
    
    func eventCoordinator(context: EventContext) -> EventCoordinator {
        .init(assembly: self, context: context)
    }
    
    func menuCoordinator() -> MenuCoordinator {
        .init(assembly: self)
    }
    
    func eventCreateCoordinator() -> EventCreateCoordinator {
        .init(assembly: self)
    }
    
    func profileCoordinator() -> ProfileCoordinator {
        .init(assembly: self)
    }
    
    func reviewCoordinator(eventId: String?) -> ReviewCoordinator {
        .init(assembly: self, context: eventId)
    }
    
    func tabBarCoordinator() -> TabBarCoordinator {
        .init(assembly: self)
    }
    
    func conversationsCoordinator() -> ConversationsCoordinator {
        .init(assembly: self)
    }
}
