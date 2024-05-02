import Foundation
import UIKit
import Firebase

final class AuthCoordinator: Coordinator<Assembly, UINavigationController, Void> {
    
    override init(assembly: Assembly) {
        super.init(assembly: assembly)
    }
    
    override func make() -> UIViewController? {
        let controller = assembly.authVC()
        
        controller.onReg = { [weak self] in
            guard let self = self else {
                return
            }
            
            self.backTo(coordinator: self.assembly.regCoordinator(), animated: true)
        }
        
        return controller
    }
    
}
