import UIKit
import Firebase

final class ReviewCoordinator: Coordinator<Assembly, UINavigationController, String?> {
    
    override init(assembly: Assembly, context: String?) {
        super.init(assembly: assembly, context: context)
    }
    
    override func make() -> UIViewController? {
        guard let context = context else {
            return nil
        }
        
        let controller = assembly.reviewVC(eventId: context)
        
        //MARK: On profile
        controller.onProfile = { [weak self] in
            guard let self = self else {
                return
            }
            
            self.backTo(coordinator: self.assembly.profileCoordinator(), animated: true)
        }
    
        return controller
    }
    
}
