import UIKit
import Firebase

final class ConversationsCoordinator: Coordinator<Assembly, UINavigationController, String?> {
    
    override init(assembly: Assembly) {
        super.init(assembly: assembly)
    }
    
    override func make() -> UIViewController? {
        let controller = assembly.conversationsVC()
//
//        //MARK: On profile
//        controller.onProfile = { [weak self] in
//            guard let self = self else {
//                return
//            }
//            
//            self.backTo(coordinator: self.assembly.profileCoordinator(), animated: true)
//        }
    
        return controller
    }
    
}
