import Foundation
import UIKit

final class RegCoordinator: Coordinator<Assembly, UINavigationController, Void> {
    
    override init(assembly: Assembly) {
        super.init(assembly: assembly)
    }
    
    override func make() -> UIViewController? {
        let controller = assembly.regVC()
        
        controller.onAuth = { [weak self] in
            guard let self = self else {
                return
            }
            
            print("Переход на экран авторизации")
            
            let coordinator = self.assembly.authCoordinator()
            
            self.start(
                coordinator: coordinator,
                on: self.root,
                animated: true
            )
        }

        return controller
    }
    
}
