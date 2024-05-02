import Foundation
import UIKit

final class ProfileCoordinator: Coordinator<Assembly, UINavigationController, Void> {
    
    override init(assembly: Assembly) {
        super.init(assembly: assembly)
    }
    
    override func make() -> UIViewController {
        let controller = assembly.profileVC()
        
        controller.onReview = { [weak self] eventId in
            guard let self = self else {
                return
            }
            
            start(
                coordinator: self.assembly.reviewCoordinator(eventId: eventId),
                on: self.root,
                animated: true
            )
        }
        
        return controller
    }
}
